# OpenDCS Plugins

Repository to hold plugin examples and tests.

A working installation of OpenDCS is required to use the plugins in this
repository.

## Building

Currently the OpenDCS `autoconf` setup uses `lib` for `libdir` but `meson`
defaults to `lib64` so that gets set here to avoid doing things the correct way.

```bash
meson --libdir=/usr/local/lib \_build
ninja -C \_build
sudo ninja -C \_build
```

## Running

```bash
export GI_TYPELIB_PATH=/usr/local/lib/girepository-1.0/:$GI_TYPELIB_PATH
dcsg -f /path/to/some/config.xml
```
