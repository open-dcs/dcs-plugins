dcs_log_dep = dependency('dcs-log-0.2', version: '>= 0.2')

backend_deps = common_deps + [
  dcs_log_dep
]

subdir('sub-analyzer')

status += [
  'Backends:',
  '',
  'SUB Data Analyzer .............. : @0@'.format(get_option('with_backend_sub_analyzer')),
  '', ''
]
