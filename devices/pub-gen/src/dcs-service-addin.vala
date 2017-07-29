public class Dcs.PubGenServiceAddin : GLib.Object, Dcs.Net.ServiceProvider {

    public Dcs.Net.Service service { get; construct set; }

    private Dcs.Net.Publisher publisher;

    private bool running = false;

    public void activate () {
        debug ("pubgen - activate");
    }

    public void deactivate () {
        debug ("pubgen - deactivate");
    }

    public void start () {
        debug ("pubgen - start");

        void * buf = Dcs.PubGen.pack (new Dcs.Message ());
        Dcs.PubGen.unpack (buf);
        delete buf;

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

    private async void send_messages () throws ThreadError {
        /* XXX Just some data for testing */
        var json = """
            {'measurement':[
                {'channel':'ai0','value':0.0},
                {'channel':'ai1','value':1.0}
            ]}
        """;
        var payload = Json.from_string (json);

        new Thread<void*> (null, () => {
            try {
                while (running) {
                    Dcs.Message message = new Dcs.Message.object ("msg0", payload);
                    publisher.send_message (message);
                    Posix.sleep (1);
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
