public class Dcs.PubGenServiceAddin : GLib.Object, Dcs.Net.ServiceProvider {

    public Dcs.Net.Service service { get; construct set; }

    private Dcs.Net.Publisher;

    public void activate () {
        debug ("pubgen - activate");
    }

    public void deactivate () {
        debug ("pubgen - deactivate");
    }

    public void start () {
        debug ("pubgen - start");
    }

    public void pause () {
        debug ("pubgen - pause");
    }

    public void stop () {
        debug ("pubgen - stop");
    }
}
