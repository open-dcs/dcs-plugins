if get_option('with_device_pub_gen')

add_project_arguments(['--vapidir', join_paths(meson.current_source_dir(), 'vapi')],
                      language: 'vala')

util_vapi = meson.get_compiler('vala').find_library('util', dirs: join_paths(meson.current_source_dir(), 'vapi'))
util_dep = declare_dependency(dependencies: [util_vapi])

subdir('src')
subdir('data')

endif
