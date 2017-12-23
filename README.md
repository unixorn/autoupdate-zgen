# autoupdate-zgen

[zgen](https://github.com/tarjoilija/zgen) doesn't do automatic updates like [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh). **autoupdate-zgen** sets up easy automatic updating, both of zgen and the bundles loaded in your configuration.

Activate with `zgen load unixorn/autoupdate-zgen` and regenerate your `init.zsh` file.

## Configuration

* set `ZGEN_PLUGIN_UPDATE_DAYS` before calling the bundle if you don't want
the default value of 7 days.
* set `ZGEN_SYSTEM_UPDATE_DAYS` before calling the bundle if you don't want
the default value of 7 days.
