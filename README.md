# autoupdate-zgen

## Status

[![License](https://img.shields.io/github/license/unixorn/autoupdate-zgen.svg)](https://opensource.org/licenses/Apache-2.0)
[![Build Status](https://travis-ci.org/unixorn/autoupdate-zgen.svg?branch=master)](https://travis-ci.org/unixorn/autoupdate-zgen)
[![GitHub stars](https://img.shields.io/github/stars/unixorn/autoupdate-zgen.svg)](https://github.com/unixorn/autoupdate-zgen/stargazers)
[![Code Climate](https://codeclimate.com/github/unixorn/autoupdate-zgen/badges/gpa.svg)](https://codeclimate.com/github/unixorn/autoupdate-zgen)
[![Issue Count](https://codeclimate.com/github/unixorn/autoupdate-zgen/badges/issue_count.svg)](https://codeclimate.com/github/unixorn/autoupdate-zgen)

[zgen](https://github.com/tarjoilija/zgen) and [zgenom](https://github.com/jandamm/zgenom) both don't include an automatic update function like [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh) does.

**autoupdate-zgen** sets up easy automatic updating, both of zgenom or zgen and the plugins loaded in your configuration.

Activate with `zgenom load unixorn/autoupdate-zgen` or `zgen load unixorn/autoupdate-zgen` and regenerate your `init.zsh` file.

## Configuration

* Set `ZGEN_PLUGIN_UPDATE_DAYS` before calling the bundle if you don't want the default value of 7 days.
* Set `ZGEN_SYSTEM_UPDATE_DAYS` before calling the bundle if you don't want the default value of 7 days.
