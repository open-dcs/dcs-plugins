project('pub-gen', 'vala', 'c',
        license: 'GPL3+',
        version: '0.1.0'
)

version_split = meson.project_version().split('.')
MAJOR_VERSION = version_split[0]
MINOR_VERSION = version_split[1]
MICRO_VERSION = version_split[2]

pkglibdir_abs = join_paths(get_option('prefix'), get_option('libdir'), meson.project_name())
pkglibdir = join_paths(get_option('libdir'), meson.project_name())

plugindir = join_paths(get_option('libdir'), 'dcs/devices')
plugindatadir = join_paths(get_option(), 'dcs/device')

plugin_link_deps = join_paths(meson.current_source_dir(), 'plugins.map')
plugin_link_args = [ '-W1,--version-script,' + plugin_link_deps ]

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
]

add_project_arguments(['--target-glib', '2.44'], language: 'vala')
add_project_arguments(['--vapidir', join_paths(meson.current_source_dir(), 'vapi')],
                      language: 'vala')

dcs_core_dep = dependency('dcs-core-0.2', version: '>= 0.2')
dcs_daq_dep = dependency('dcs-daq-0.2', version: '>= 0.2')
dcs_net_dep = dependency('dcs-net-0.2', version: '>= 0.2')
gio_dep = dependency('gio-2.0', version: '>= 2.48')
peas_dep = dependency('libpeas-1.0', version: '>= 1.16.0')
posix_dep = meson.get_compiler('vala').find_library('posix')

gnome = import('gnome')
i18n = import('i18n')

subdir('src')
subdir('data')

meson.add_install_script('build-aux/meson/meson_post_install.py')

# 'dist' will be used by meson, avoid conflicting
run_target('builder-dist',
  command: [
    find_program('build-aux/meson/meson_dist.sh'),
    meson.project_version(),
    meson.project_name(),
  ]
)

message('\n  '.join(status))
