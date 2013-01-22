Description
===========

Installs and configures the [Tracelytics](http://www.tracelytics.com/) daemon. Optionally, will install and configure other instrumentation (e.g. Apache, Python, etc.).

Requirements
============

Tracelytics
-----------

Go to [Tracelytics](http://www.tracelytics.com/) and create an account. An access key, which is provided by Tracelytics, will be required.

Platform
--------

* Debian, Ubuntu
* CentOS 6

Tested on Ubuntu 10.04.3 LTS (Lucid). RHEL and Fedora are not currently tested but should work with the same components as CentOS.

Cookbooks
---------

* [apache2](https://github.com/opscode-cookbooks/apache2)
* [apt](https://github.com/opscode-cookbooks/apt)
* [python](https://github.com/opscode-cookbooks/python)
* [yum](https://github.com/opscode-cookbooks/yum)
Attributes
==========

default
-------

* `node['tracelytics']['access_key']` **required** Your Tracelytics access key.

apache
------

* `node['tracelytics']['trace_mode']` **optional** Sets when traces should be initiated. Valid values are `always`, `through`, and `never`. Defaults to `always`. [More](http://support.tracelytics.com/kb/configuration/configuring-apache)
* `node['tracelytics']['sampling_rate']` **optional** The number of requests out of every million that will be traced. Defaults to `300000`. [More](http://support.tracelytics.com/kb/configuration/configuring-apache)

Recipes
=======

default
-------

Includes the `tracelytics::apt` recipe, configures your `/etc/tracelytics.conf`, and installs the `liboboe0`, `liboboe-dev`, `tracelyzer` packages.

apache
------

Installs `libapache2-mod-oboe` and configures your `/etc/apache2/mods-available/oboe.conf`.

apt
---

Configures the Tracelytics repository and installs their packaging key for apt based systems.

python
------

Uses `pip` to install the `oboe` Python package.

mysql
-----

**NOTE:** This recipe is currently not working. It is recommended you build the package manually and add it to your own apt repository. Downloads the MySQL client library patch from Tracelytics and builds a Debian package with the modified source. Installs the package after a successful build, but will not run again after the initial build.

yum
---

Configures the tracelytics repository and installs the packaging key for yum based systems.
