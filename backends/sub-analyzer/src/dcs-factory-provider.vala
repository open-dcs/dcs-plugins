public class Dcs.SubAnalyzerFactory : GLib.Object, Dcs.FooFactory {

    public virtual Dcs.Node produce (Type type) throws GLib.Error {
        Dcs.Node node = null;
        return node;
    }

    public virtual Dcs.Node produce_from_config (Dcs.ConfigNode config)
                                                 throws GLib.Error {
        Dcs.Node node = null;
        return node;
    }

    public virtual Dcs.Node produce_from_config_list (Gee.List<Dcs.ConfigNode> config)
                                                      throws GLib.Error {
        Dcs.Node node = null;
        return node;
    }
}

public class Dcs.SubAnalyzerFactoryProvider : GLib.Object, Dcs.FactoryProvider {

    public Dcs.FooFactory factory { get; construct set; }

    construct {
        factory = new Dcs.SubAnalyzerFactory ();
    }
}
