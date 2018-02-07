sub_analyzer_sources = [
  'config.vapi',
  'sub-analyzer-backend.vala',
  'dcs-service-addin.vala',
  'dcs-config-provider.vala',
  'dcs-factory-provider.vala',
  'pack-util.c',
  'pack-util.h'
]

sub_analyzer_deps = backend_deps

sub_analyzer_c_args = [
  '-DLOG_DOMAIN="sub-analyzer-backend"',
  '-DGETTEXT_PACKAGE="opendcs"',
  '-DPACKAGE_DATADIR="@0@"'.format(join_paths(get_option('prefix'),
                                              get_option('datadir'),
                                              'dcs'))
]

shared_module('sub-analyzer-backend', sub_analyzer_sources,
  dependencies: sub_analyzer_deps,
        c_args: sub_analyzer_c_args,
     link_args: plugin_link_args,
  link_depends: plugin_link_deps,
       install: true,
   install_dir: backenddir
)
