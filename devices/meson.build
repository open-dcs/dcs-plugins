dcs_daq_dep = dependency('dcs-daq-0.2', version: '>= 0.2')

device_deps = common_deps + [
  dcs_daq_dep
]

subdir('pub-gen')

status += [
  'Devices:',
  '',
  'PUB Data Generator ............. : @0@'.format(get_option('with_device_pub_gen')),
  '', ''
]
