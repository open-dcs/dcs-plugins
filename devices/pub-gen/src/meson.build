pub_gen_sources = [
  'config.vapi',
  'pub-gen-device.vala',
  'dcs-service-addin.vala',
  'dcs-config-provider.vala',
  'dcs-factory-provider.vala',
  'pack-util.c',
  'pack-util.h'
]

pub_gen_deps = device_deps + [
  util_dep
]

pub_gen_c_args = [
  '-DLOG_DOMAIN="pub-gen-device"',
  '-DGETTEXT_PACKAGE="opendcs"',
  '-DPACKAGE_DATADIR="@0@"'.format(join_paths(get_option('prefix'),
                                              get_option('datadir'),
                                              'dcs'))
]

shared_module('pub-gen-device', pub_gen_sources,
  dependencies: pub_gen_deps,
        c_args: pub_gen_c_args,
     link_args: plugin_link_args,
  link_depends: plugin_link_deps,
       install: true,
   install_dir: devicedir
)
