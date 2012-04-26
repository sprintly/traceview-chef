# This recipe only sets up your /etc/tracelytics.conf. Everything else should
# be included in your run list depending on your distribution or stack.
# 
# Use the recipes for your distribution/stack setup.
# - tracelytics::apt for Ubuntu/Debian distributions
# - tracelytics::apache for Apache instrumentation
# - tracelytics::python for Python instrumentation

# For now, we assume you're on a Debian/Ubuntu system. If you are not
# this recipe will fail horribly.
include_recipe "tracelytics::apt"

# Be sure to set your access_key in an environment/role/node attribute.
template "/etc/tracelytics.conf" do
    source "etc/tracelytics.conf.erb"
end

# Be sure to include the tracelytics::apt recipe before this in your
# run list. Need to make this more agnostic on distribution, but
# we don't use RedHat/CentOS and I'm lazy.
%w{liboboe0 liboboe-dev tracelyzer}.each do |package_name|
    package package_name do
        action :install
    end
end
