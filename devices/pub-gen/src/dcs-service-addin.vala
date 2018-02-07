public class Dcs.PubGenServiceAddin : GLib.Object, Dcs.Net.ServiceProvider {

    public Dcs.Net.Service service { get; construct set; }

    private Dcs.Net.Publisher publisher;

    private bool running = false;

    private int n_channels = 512;

    private int msg_per_second = 100;

    private uint64 msg_num = 0;

    private bool pack = false;

    private bool compress = false;

    public void activate () {
        debug ("pubgen - activate");
    }

    public void deactivate () {
        debug ("pubgen - deactivate");
    }

    public void start () {
        debug ("pubgen - start");

        /*
         *void * buf = Dcs.Util.pack (new Dcs.Message ());
         *Dcs.Util.unpack (buf);
         *delete buf;
         */

        var model = service.get_model ();
        var net = model.@get ("net");
        var publishers = net.get_children (typeof (Dcs.Net.Publisher));
        /* FIXME This is dumb, get_children shouldn't allocate an empty list */
        if (publishers == null) {
            warning ("Couldn't find any publishers");
            return;
        } else if (publishers.size == 0) {
            warning ("Couldn't find any publishers");
            return;
        }
        publisher = (Dcs.Net.Publisher) publishers.@get (1);
        /* TODO Add more verbose checking */
        if (publisher == null) {
            warning ("Couldn't get publisher");
            running = false;
        } else {
            running = true;
            send_messages.begin ((obj, res) => {
                try {
                    send_messages.end (res);
                } catch (ThreadError e) {
                    error (e.message);
                }
            });
        }
    }

    public void pause () {
        debug ("pubgen - pause");
    }

    public void stop () {
        debug ("pubgen - stop");
        running = false;
    }

    private float gen_value (int phase) {
        return 0.0f;
    }

    private string gen_msg_data () {
        var builder = new StringBuilder ();
        builder.append ("{'measurement':[");
        for (int i = 0; i < n_channels; i++) {
            builder.append_printf ("{'channel':'ai%02d','value':%.3f}", i, gen_value (i));
            if (i != n_channels - 1) {
                builder.append (",");
            }
        }
        builder.append ("]}");
        return builder.str;
    }

    private void compress_data (DataInputStream source, DataOutputStream dest) throws Error {
        convert (source, dest, new ZlibCompressor (ZlibCompressorFormat.GZIP));
    }

    private void convert (DataInputStream source, DataOutputStream dest, Converter converter) throws Error {
        var conv_stream = new ConverterOutputStream (dest, converter);
        conv_stream.splice (source, 0);
    }

    private async void send_messages () throws ThreadError {
        new Thread<void*> (null, () => {
            Mutex mutex = Mutex ();
            Cond cond = Cond ();
            int64 end_time;
            int dt = 1000 / msg_per_second;

            try {
                while (running) {
                    /* Generate data for testing */
                    mutex.lock ();
                    string json = gen_msg_data ();
                    string msg_id = "msg%012d".printf ((int) msg_num++);
                    var payload = Json.from_string (json);
                    var msg = new Dcs.Message.object (msg_id, payload);
                    if (pack) {
                        /*
                         *debug ("before");
                         *size_t len;
                         *uint8[]? data = Dcs.Util.pack (msg, out len);
                         *debug ("length: %d", (int) len);
                         *if (data != null) {
                         *    debug ("packed something");
                         *}
                         *publisher.send_packed_message (data);
                         *debug ("after");
                         */
                    } else if (compress) {
                        var msg_data = msg.serialize ();
                        var @is = new MemoryInputStream.from_data (msg_data.data, GLib.free);
                        var dis = new DataInputStream (@is);
                        var zos = new MemoryOutputStream (null, GLib.realloc, GLib.free);
                        var dzos = new DataOutputStream (zos);

                        compress_data (dis, dzos);
                        uint8[] compressed = zos.steal_data ();
                        compressed.length = (int) zos.get_data_size ();
                        publisher.send_packed_message (compressed);
                    } else {
                        publisher.send_message (msg);
                    }
                    end_time = get_monotonic_time () + dt * TimeSpan.MILLISECOND;
                    while (cond.wait_until (mutex, end_time)) { ; }
                    mutex.unlock ();
                }
            } catch (GLib.Error e) {
                error (e.message);
            }

            Idle.add (send_messages.callback);
            return null;
        });

        yield;
    }
}
