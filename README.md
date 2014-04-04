Description
===========

Installs and configures the [TraceView](http://www.appneta.com/products/traceview/) daemon. Optionally, will install and configure other instrumentation (e.g. Apache, Python, etc.).

Requirements
============

TraceView
---------

Go to [TraceView](http://www.appneta.com/products/traceview/) and create an account. An access key, which is provided by TraceView, will be required.

Platform
--------

* Debian, Ubuntu

Tested on Ubuntu 10.04.3 LTS (Lucid). RHEL, CentOS, and Fedora are not currently supported, but could be with little effort.

Cookbooks
---------

* [apache2](https://github.com/opscode/cookbooks/tree/master/apache2)
* [apt](https://github.com/opscode/cookbooks/tree/master/apt)
* [python](https://github.com/opscode/cookbooks/tree/master/python)

Attributes
==========

default
-------

* `node['tracelytics']['access_key']` **required** Your TraceView access key.

apache2
-------

* `node['tracelytics']['trace_mode']` **optional** Sets when traces should be initiated. Valid values are `always`, `through`, and `never`. Defaults to `always`. [More](http://support.tracelytics.com/kb/configuration/configuring-apache)
* `node['tracelytics']['sampling_rate']` **optional** The number of requests out of every million that will be traced. Defaults to `300000`. [More](http://support.tracelytics.com/kb/configuration/configuring-apache)

Recipes
=======

default
-------

Includes the `tracelytics::apt` recipe, configures your `/etc/tracelytics.conf`, and installs the `liboboe0`, `liboboe-dev`, `tracelyzer` packages.

apache2
-------

Installs `libapache2-mod-oboe` and configures your `/etc/apache2/mods-available/oboe.conf`.

apt
---

Configures the TraceView repository and installs their packaging key.

python
------

Uses `pip` to install the `oboe` Python package.

mysql
-----

**NOTE:** This recipe is currently not working. It is recommended you build the package manually and add it to your own apt repository. Downloads the MySQL client library patch from TraceView and builds a Debian package with the modified source. Installs the package after a successful build, but will not run again after the initial build.
