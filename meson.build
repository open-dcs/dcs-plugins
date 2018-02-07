project('dcs-plugins', 'vala', 'c',
        license: 'GPL3+',
        version: '0.1.0'
)

version_split = meson.project_version().split('.')
MAJOR_VERSION = version_split[0]
MINOR_VERSION = version_split[1]
MICRO_VERSION = version_split[2]

plugindir = join_paths(get_option('libdir'), 'dcs/plugins')
plugindatadir = join_paths(get_option('datadir'), 'dcs/plugin')
pluginconfdir = join_paths(get_option('sysconfdir'), 'dcs/plugin')
backenddir = join_paths(get_option('libdir'), 'dcs/backends')
backenddatadir = join_paths(get_option('datadir'), 'dcs/backend')
backendconfdir = join_paths(get_option('sysconfdir'), 'dcs/backend')
controllerdir = join_paths(get_option('libdir'), 'dcs/controllers')
controllerdatadir = join_paths(get_option('datadir'), 'dcs/controller')
controllerconfdir = join_paths(get_option('sysconfdir'), 'dcs/controller')
devicedir = join_paths(get_option('libdir'), 'dcs/devices')
devicedatadir = join_paths(get_option('datadir'), 'dcs/device')
deviceconfdir = join_paths(get_option('sysconfdir'), 'dcs/device')

plugin_link_deps = join_paths(meson.current_source_dir(), 'plugins.map')
plugin_link_args = [ '-Wl,--version-script,' + plugin_link_deps ]

status = [
  '', '',
  '@0@ @1@'.format(meson.project_name(), meson.project_version()),
  '', '',
  'Version ............... : @0@'.format(meson.project_version()),
  'Build Type ............ : @0@'.format(get_option('buildtype')),
  '',
  'Prefix ................ : @0@'.format(get_option('prefix')),
  'Libdir ................ : @0@'.format(join_paths(get_option('prefix'), get_option('libdir'))),
  '',
  'Examples .............. : @0@'.format(get_option('with_examples')),
  '', ''
]

add_project_arguments(['--target-glib', '2.44'], language: 'vala')
add_project_arguments(['--thread'], language: 'vala')

dcs_core_dep = dependency('dcs-core-0.2', version: '>= 0.2')
dcs_net_dep = dependency('dcs-net-0.2', version: '>= 0.2')
gio_dep = dependency('gio-2.0', version: '>= 2.48')
cld_dep = dependency('cld-0.3', version: '>= 0.3')
json_dep = dependency('json-glib-1.0', version: '>= 1.2')
peas_dep = dependency('libpeas-1.0', version: '>= 1.16.0')
soup_dep = dependency('libsoup-2.4', version: '>= 2.48.0')
xml_dep = dependency('libxml-2.0', version: '>= 2.9.0')
zmq_dep = dependency('libzmq', version: '>= 3.2.0')
msgpack_dep = dependency('msgpack', version: '>= 0.9.0')
posix_dep = meson.get_compiler('vala').find_library('posix')

add_project_arguments(['--vapidir', join_paths(meson.current_source_dir(), 'vapi')],
                      language: 'vala')

util_vapi = meson.get_compiler('vala').find_library('util', dirs: join_paths(meson.current_source_dir(), 'vapi'))
util_dep = declare_dependency(dependencies: [util_vapi])

gnome = import('gnome')
i18n = import('i18n')

common_deps = [
  dcs_core_dep,
  dcs_net_dep,
  gio_dep,
  cld_dep,
  json_dep,
  peas_dep,
  soup_dep,
  xml_dep,
  msgpack_dep,
  posix_dep,
  util_dep
]

subdir('backends')
subdir('controllers')
subdir('devices')
subdir('plugins')
subdir('examples')

meson.add_install_script('build-aux/meson/meson_post_install.py')

# 'dist' will be used by meson, avoid conflicting
run_target('dcs-plugins-dist',
  command: [
    find_program('build-aux/meson/meson_dist.sh'),
    meson.project_version(),
    meson.project_name(),
  ]
)

message('\n  '.join(status))
