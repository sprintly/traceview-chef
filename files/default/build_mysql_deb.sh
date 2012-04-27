#!/bin/bash
#
# Builds MySQL client library packages instrumented with event
# reporters for the Tracelytics Oboe library.
#
# For assistance, please visit http://support.tracelytics.com or
# contact support@tracelytics.com.
#
# (c) 2011 Tracelytics, Inc.

command_exists() {
    hash "$1" > /dev/null 2>&1
}

exit_with_error() {
    echo "=== ERROR: $1"
    echo "=== Please contact us for assistance building on this platform, by visiting"
    echo "=== http://support.tracelytics.com or contacting support@tracelytics.com."
    exit 1
}

check_errs() {
    if [ "${1}" -ne "0" ]; then
        echo "=== ERROR (${1}): ${2}"
        echo "=== Please contact us for assistance building on this platform, by visiting"
        echo "=== http://support.tracelytics.com or contacting support@tracelytics.com."
        exit ${1}
    fi
}

debian_package_installed() {
    STATUS=$(dpkg-query -W -f='${Status}\n' "$1" 2>/dev/null)
    if [ "$?" = 0 ]; then
        echo "$STATUS" | grep " installed$" > /dev/null
    else
        false
    fi
}

echo_banner() {
    echo && echo "=== $@"
}

SHOWRUN () {
    # show important commands as they're executed, so as not to scare users
    echo "===  " $@
    echo
    $@
}

# debugging
#set -x # show all commands
#set -e # stop at first non-zero exit code

if [ $# != 1 ]; then
    echo "=== Usage: $0 /path/to/mysql-tracelytics.diff"
    exit 1
fi

# check if diff file exists
MYDIFF=$1
if [ ! -f $MYDIFF ]; then
    exit_with_error "File $MYDIFF not found."
fi

echo "==="
echo "=== Welcome to the Tracelytics build script for libmysqlclient!"
echo "=== This script will help you build .deb packages for libmysqlclient which support"
echo "=== tracing MySQL requests using the Tracelytics liboboe instrumentation library."
echo "==="

command_exists apt-cache || exit_with_error "Command 'apt-cache' not found; this build script only supports Debian/Ubuntu currently."
command_exists apt-get || exit_with_error "Command 'apt-get' not found; this build script only supports Debian/Ubuntu currently."

if ! debian_package_installed dpkg-dev ||
   ! debian_package_installed dpatch ||
   ! debian_package_installed fakeroot ||
   ! debian_package_installed devscripts; then
    echo "=== This script requires the following Debian build tools packages: dpkg-dev, dpatch, devscripts, fakeroot"
    echo "=== Running apt-get to install these tools (requires sudo):"
    SHOWRUN sudo apt-get --no-install-recommends install dpkg-dev dpatch devscripts fakeroot
    check_errs $? "Couldn't install dpkg-dev dpatch devscripts, quitting."
fi

if ! debian_package_installed liboboe-dev; then
    echo "=== You need the liboboe-dev package, which is a base package provided by"
    echo "=== the Tracelytics installer.  Please follow the instructions at:"
    echo "==="
    echo "===   http://support.tracelytics.com/kb/installation-instructions/installing-base-packages"
    echo "==="
    echo "=== to find out how to add our apt repository and install Tracelytics packages."
    echo "==="
    echo "=== Attempting to install liboboe-dev (requires sudo):"
    SHOWRUN sudo apt-get install liboboe-dev
    check_errs $? "Couldn't install liboboe-dev, quitting."
fi

BUILDDIR=.
CODENAME=$(lsb_release -c -s)

case "$CODENAME" in
    lenny|hardy|jaunty)
        # patch diff to apply on MySQL 5.0.51a
        OLDMYDIFF=$MYDIFF
        MYDIFF="${OLDMYDIFF}.5.0.51a"
        sed 's/my_free((uchar\*) result/my_free((gptr) result/g' $OLDMYDIFF > $MYDIFF
        check_errs $? "Patching ${MYDIFF} for 5.0.51a failed, quitting."
        ;;
    squeeze|lucid|maverick|natty|oneiric) 
        # these platforms use MySQL 5.1 and are supported
        ;;
    "") exit_with_error "Couldn't detect OS distribution and codename (lsb_release not installed?)";;
    *) exit_with_error "Sorry, this script does not support the ${CODENAME} distribution.";;
esac

echo_banner "First, we'll download the latest package definitions (requires sudo)"
SHOWRUN sudo apt-get update -qq
check_errs $? "Error running apt-get update, quitting."

MYCLIENT=$(apt-cache search libmysqlclient | grep ^libmysqlclient | grep -v -- '-dev' | awk '{print $1}' | sort | tail -n1)
echo_banner "Detected MySQL client for this platform ($CODENAME): $MYCLIENT"

echo_banner "Downloading build dependencies (requires sudo):"
SHOWRUN sudo apt-get -y build-dep $MYCLIENT
check_errs $? "Failed to install build dependencies for $MYCLIENT, quitting."

# additional build dependency: libssl-dev (for -lcrypto)
sudo apt-get install -q -y --no-install-recommends libssl-dev
check_errs $? "Failed to install libssl-dev build dependency, quitting."

echo_banner "Downloading source for $MYCLIENT to current directory:"
SHOWRUN apt-get source $MYCLIENT
check_errs $? "Failed to download source package for $MYCLIENT, quitting."

# Figure out where apt-get just put the downloaded source
DFSGDIR=$(find $BUILDDIR -maxdepth 1 -mindepth 1 -type d -name mysql-\*)

# Get version number from changelog file
#  looks like: mysql-5.1 (5.1.54-1ubuntu4) natty; urgency=low
OLDVER=$(head $DFSGDIR/debian/changelog -n1 | awk '{print $2}' | sed 's/(\(.*\))/\1/')

# Use explicit dependency to current version string from changelog,
# rather than the ${source:Version} macro, so that the installed
# mysql-common package doesn't have to be a Tracelytics package (our
# patch only affects the libmysqlclient package)
echo_banner "Updating dependency file for $MYCLIENT..."
sed -i "s/^Depends: mysql-common (>= \${source:Version})/Depends: mysql-common (>= ${OLDVER}), liboboe0/" $DFSGDIR/debian/control
check_errs $? "Can't set mysql-common dependency."
sed -i "s/^Build-Depends:/Build-Depends: liboboe-dev, libssl-dev,/" $DFSGDIR/debian/control
check_errs $? "Couldn't set build dependency for oboe, quitting."

# Set our name/email: this will appear in the package changelog, etc
#  build user doesn't have GPG secret for packages@tracelytics.com so we set -uc below
# TODO: allow user to supply their own GPG key for package signing purposes
export DEBFULLNAME="Tracelytics MySQL Package Script"
export DEBEMAIL=packages@tracelytics.com
DTSTAMP=$(date +%Y%m%d%H%M)

# Convert our diff into debian dpatch format, and add to list of patches
echo_banner "Adding Tracelytics instrumentation to Debian patch directory..."
dpatch patch-template -p "200_tracelytics" "Add Tracelytics liboboe event reporter" < $MYDIFF > $DFSGDIR/debian/patches/200_tracelytics.dpatch
check_errs $? "Error running dpatch."
echo "200_tracelytics" >> $DFSGDIR/debian/patches/00list


# Add our patch to the changelog (this bumps the version number to +tracelyticsDATECODENAME)
echo_banner "Adding Tracelytics patch to the Debian changelog..."
cd $DFSGDIR
EDITOR=true debchange --distribution ${CODENAME} -v ${OLDVER}+tracelytics${DTSTAMP}${CODENAME} 'Applied liboboe event reporter patch from Tracelytics (www.tracelytics.com)'
check_errs $? "Error running debchange."

if [ "$CODENAME" = "hardy" ]; then 
    # there is an autotools bug in the hardy MySQL package requiring manual intervention
    # http://ubuntuforums.org/archive/index.php/t-1150160.html
    sed -i 's/ debian\/Makefile debian\/defs\.mk debian\/control dnl/ dnl/' configure.in
    check_errs $? "Failed to apply package fix for hardy, quitting."
    # applying "upstreamdebiandir" patch in advance seems to work
    patch --silent -p1 < debian/patches/90_upstreamdebiandir.dpatch
    check_errs $? "Failed to apply package fix for hardy, quitting."
    grep -v 90_upstreamdebiandir debian/patches/00list > 00list.new
    check_errs $? "Failed to apply package fix for hardy, quitting."
    mv 00list.new debian/patches/00list
    check_errs $? "Failed to apply package fix for hardy, quitting."
fi

cd .. # leave $DFSGDIR

# Actually build the package: this builds the MySQL server & common
# packages along with the client packages; there doesn't seem to be
# any good way to get around that, so we don't.
export DEB_BUILD_OPTIONS=nocheck
BUILDLOG=$(readlink -f -n build-mysql-${DTSTAMP}${CODENAME}.log)
echo_banner "Running dpkg-buildpackage to compile MySQL packages. This will take quite a while."
echo "=== To check the progress of your build, try this in another terminal:"
echo "===     tail -f ${BUILDLOG}"

cd $DFSGDIR
SHOWRUN dpkg-buildpackage -b -uc > ${BUILDLOG} 2>&1
# It's hard to check the return code here; dpkg-buildpackage often
# returns non-zero error codes even if packages were successfully
# built. This isp robably because a few of the Ubuntu/Debian package
# tests fail (for non-Tracelytics-related reasons).
cd ..

PKGS=$(ls ${BUILDDIR}/*.deb)
check_errs $? "Build didn't produce any .deb packages!"

THEPKG=$(ls ${BUILDDIR}/${MYCLIENT}_*.deb)
check_errs $? "Can't find package for $MYCLIENT"

echo
echo "=== dpkg-buildpackage has completed. To trace MySQL requests using Tracelytics oboe, "
echo "=== you only need to install the $MYCLIENT package."
echo "=== "
echo "=== The instrumented MySQL client library for $CODENAME is contained in:"
echo "===   $THEPKG."
echo "=== "
echo "=== You may continue to use your distribution's shipped packages for all other MySQL"
echo "=== packages, such as mysql-server(-core), mysql-common, mysql-client(-core), etc."
echo "=== Feel free to delete all other build output and .deb files."
echo "=== "
echo "=== Thanks for taking the time to build a MySQL client instrumented with our event reporting!"
echo "=== "
echo "=== For more assistance, please visit http://support.tracelytics.com"
