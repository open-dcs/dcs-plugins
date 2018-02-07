[ModuleInit]
public void peas_register_types (GLib.TypeModule module) {
    var peas = module as Peas.ObjectModule;

    peas.register_extension_type (typeof (Dcs.Net.ServiceProvider), typeof (Dcs.SubAnalyzerServiceAddin));
    peas.register_extension_type (typeof (Dcs.ConfigProvider), typeof (Dcs.SubAnalyzerConfigProvider));
    peas.register_extension_type (typeof (Dcs.FactoryProvider), typeof (Dcs.SubAnalyzerFactoryProvider));
}
