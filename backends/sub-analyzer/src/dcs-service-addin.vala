public class Dcs.SubAnalyzerServiceAddin : GLib.Object, Dcs.Net.ServiceProvider {

    private struct Boxed {
        public uint8[] data;
    }

    public Dcs.Net.Service service { get; construct set; }

    private Dcs.Net.Subscriber subscriber;

    private bool running = false;

    private Gee.Queue<Boxed?> queue;

    private Mutex mutex = Mutex ();

    private Cond cond = Cond ();

    private int n_prev = 0;

    private bool decompress = false;

    private FileIOStream stats;
    private int n_msg = 0;
    private int bps = 0;
    private int n_missed = 0;
    private int t_msg_tot = 0;

    public void activate () {
        debug ("subanalyzer - activate");
    }

    public void deactivate () {
        debug ("subanalyzer - deactivate");
    }

    public void start () {
        debug ("subanalyzer - start");

        queue = new Gee.ArrayQueue<Boxed?> ();
        var date = new DateTime.now (new TimeZone.local ());
        var filename = GLib.Path.build_filename ("/tmp", "stats-%s.csv".printf (date.format ("%Y-%m-%d_%H:%M:%S")));
        var file = File.new_for_path (filename);
        stats = file.create_readwrite (FileCreateFlags.NONE);
        var os = stats.output_stream as FileOutputStream;
        size_t bytes_written;
        var header = "time(s),n_msg,bps(B/s),n_missed,t_avg_trans(us)\n";
        os.write_all (header.data, out bytes_written);

        var model = service.get_model ();
        var net = model.@get ("net");
        var subscribers = net.get_descendants (typeof (Dcs.Net.Subscriber));
        debug (net.to_string ());
        if (subscribers == null || subscribers.size == 0) {
            warning ("Couldn't find any subscribers");
            return;
        }
        subscriber = (Dcs.Net.Subscriber) subscribers.@get (1);
        if (subscriber == null) {
            debug ("Couldn't get subscriber");
            running = false;
        } else {
            subscriber.data_received.connect (data_received_cb);
            running = true;

            process_queue.begin ((obj, res) => {
                try {
                    process_queue.end (res);
                } catch (ThreadError e) {
                    error (e.message);
                }
            });
        }
    }

    public void pause () {
        debug ("subanalyzer - pause");
    }

    public void stop () {
        debug ("subanalyzer - stop");
        subscriber = null;
        running = false;
    }

    private void decompress_data (DataInputStream source, DataOutputStream dest) throws Error {
        convert (source, dest, new ZlibDecompressor (ZlibCompressorFormat.GZIP));
    }

    private void convert (DataInputStream source, DataOutputStream dest, Converter converter) throws Error {
        var conv_stream = new ConverterOutputStream (dest, converter);
        conv_stream.splice (source, 0);
    }

    /*
     *daq-pub-gen {
     *  "msg000000001725":{
     *    "type":"object",
     *    "timestamp":1502485501401399,
     *    "payload":{
     *      "measurement":[
     *        {"channel":"ai00","value":0.0},
     *        {"channel":"ai01","value":0.0},
     *        {"channel":"ai02","value":0.0},
     *        {"channel":"ai03","value":0.0},
     *        {"channel":"ai04","value":0.0},
     *        {"channel":"ai05","value":0.0},
     *        {"channel":"ai06","value":0.0},
     *        {"channel":"ai07","value":0.0},
     *        {"channel":"ai08","value":0.0},
     *        {"channel":"ai09","value":0.0},
     *        {"channel":"ai10","value":0.0},
     *        {"channel":"ai11","value":0.0},
     *        {"channel":"ai12","value":0.0},
     *        {"channel":"ai13","value":0.0},
     *        {"channel":"ai14","value":0.0},
     *        {"channel":"ai15","value":0.0}
     *      ]
     *    }
     *  }
     *}
     */

    private void data_received_cb (uint8[] data) {
        mutex.lock ();
        var boxed = Boxed ();
        boxed.data = data;
        queue.offer (boxed);
        cond.signal ();
        mutex.unlock ();
    }

    private async void process_queue () throws ThreadError {
        int64 last_write = 0;
        int64 start_time = GLib.get_real_time ();
        new Thread<void *> (null, () => {
            while (running) {
                mutex.lock ();
                while (queue.size == 0) {
                    cond.wait (mutex);
                }
                // if not empty
                var boxed = queue.poll ();
                mutex.unlock ();

                // get timestamp for received
                int64 ts_recv = GLib.get_real_time ();
                string data = "";

                if (decompress) {
                    var zis = new MemoryInputStream.from_data (
                                    boxed.data[subscriber.filter.length+1:boxed.data.length-1],
                                    GLib.free);
                    var dzis = new DataInputStream (zis);
                    var os = new MemoryOutputStream (null, GLib.realloc, GLib.free);
                    var dos = new DataOutputStream (os);

                    try {
                        decompress_data (dzis, dos);
                        uint8[] decompressed = os.steal_data ();
                        decompressed.length = (int) os.get_data_size ();
                        stdout.printf ("Decompressed: %s\n", (string) decompressed);
                        data = (string) decompressed;
                    } catch (Error e) {
                        critical (e.message);
                    }
                } else {
                    data = (string) boxed.data;
                }

                var channels = new Gee.HashMap<string, double?> ();
                // strip filter
                string filter = "";
                string json;
                if (!decompress) {
                    filter = data.substring (0, data.index_of (" "));
                    json = data.substring (data.index_of (" "));
                } else {
                    json = data;
                }
                var root = Json.from_string (json);
                var obj = root.get_object ();
                var members = obj.get_members ();
                // read ID
                var id = members.nth_data (0);
                var n = int.parse (id.substring (3));
                var node = obj.get_member (id);
                var node_obj = node.get_object ();
                // with object ID
                //   read type
                string msg_type = node_obj.get_string_member ("type");
                //   read timestamp
                int64 ts_sent = node_obj.get_int_member ("timestamp");
                var payload = node_obj.get_member ("payload");
                var payload_obj = payload.get_object ();
                //   with payload object
                if (payload_obj.has_member ("measurement")) {
                //     if object has "measurement"
                //       with "measurement"
                    var meas = payload_obj.get_array_member ("measurement");
                //         foreach channel in array
                    foreach (var chan in meas.get_elements ()) {
                //           get channel ID
                //           get channel value
                        var chan_obj = chan.get_object ();
                        channels.@set (chan_obj.get_string_member ("channel"),
                                       chan_obj.get_double_member ("value"));
                    }
                }

                debug ("Filter:  %s", filter);
                debug ("Type:    %s", msg_type);
                debug ("Tsent:   %lld", ts_sent);
                debug ("Trecv:   %lld", ts_recv);
                debug ("Tdt:     %lld", ts_recv - ts_sent);
                debug ("Bytes:   %d", data.length);
                debug ("Msg num: %d", n);
                bool n_diff = (n == n_prev + 1) ? true : false;
                n_prev = n;
                debug ("Msg n+1: %s", n_diff.to_string ());
                debug ("Nchan:   %d", channels.size);
                foreach (var chan in channels.keys) {
                    debug ("Chan:    %s - %.3f", chan, channels.@get (chan));
                }

                /* Update stats data */
                n_msg++;
                bps += (int) data.length;
                n_missed = (!n_diff) ? n_missed + 1 : n_missed;
                t_msg_tot += (int) (ts_recv - ts_sent);

                int64 write_time = GLib.get_real_time ();
                if ((write_time - last_write) > 1000000) {
                    var os = stats.output_stream as FileOutputStream;
                    size_t bytes_written;
                    var line = "%lld,%d,%d,%d,%d\n".printf (
                                    (write_time - start_time) / 1000000,
                                    n_msg,
                                    bps,                        /* XXX not actual bps if t > 1s */
                                    n_missed,
                                    t_msg_tot / n_msg);
                    os.write_all (line.data, out bytes_written);
                    last_write = write_time;
                    /* Reset counters */
                    n_msg = 0;
                    bps = 0;
                    n_missed = 0;
                    t_msg_tot = 0;
                }
            }

            Idle.add (process_queue.callback);
            return null;
        });

        yield;
    }
}
