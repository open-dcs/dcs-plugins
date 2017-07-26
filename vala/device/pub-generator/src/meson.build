pub_gen_sources = [
  'config.vapi',
  'pub-gen-device.vala',
  'dcs-service-addin.vala',
  'dcs-config-provider.vala',
  'dcs-factory-provider.vala'
]

pub_gen_deps = [
  dcs_core_dep,
  dcs_daq_dep,
  dcs_net_dep,
  gio_dep,
  peas_dep,
  posix_dep
]

plugin_c_args = [
  '-DLOG_DOMAIN="pub-gen-device"',
  '-DGETTEXT_PACKAGE="opendcs"',
  '-DPACKAGE_DATADIR="@0@"'.format(join_paths(get_option('prefix'),
                                              get_option('datadir'),
                                              'dcs'))
]

shared_module('pub-gen-device', pub_gen_sources,
  dependencies: pub_gen_deps,
        c_args: plugin_c_args,
     link_args: plugin_link_args,
  link_depends: plugin_link_deps,
       install: true,
   install_dir: plugindir
)
