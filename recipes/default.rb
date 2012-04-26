# This recipe only sets up your /etc/tracelytics.conf. Everything else should
# be included in your run list depending on your distribution or stack.
# 
# Use the recipes for your distribution/stack setup.
# - tracelytics::apt for Ubuntu/Debian distributions
# - tracelytics::apache for Apache instrumentation
# - tracelytics::python for Python instrumentation

# Be sure to set your access_key in an environment/role/node attribute.
template "/etc/tracelytics.conf" do
    source "etc/tracelytics.conf"
end
