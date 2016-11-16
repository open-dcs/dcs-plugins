# OpenDCS Plugins

Repository to hold plugin examples and tests.

A working installation of OpenDCS is required to use the plugins in this
repository.

## Installing

The instructions here assume the development installation path prefix
`/usr/local`.

### Python

```bash
cp python/<plugin>/*.{py,plugin} /usr/local/lib/dcs/plugins/
```

## Running

```bash
export GI_TYPELIB_PATH=/usr/local/lib/girepository-1.0/:$GI_TYPELIB_PATH
dcsg -f /path/to/some/config.xml
```
