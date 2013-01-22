# This recipe only sets up your /etc/tracelytics.conf. Everything else should
# be included in your run list depending on your distribution or stack.
# 
# Use the recipes for your distribution/stack setup.
# - tracelytics::apt for Ubuntu/Debian distributions
# - tracelytics::apache for Apache instrumentation
# - tracelytics::python for Python instrumentation

case node['platform']
when "ubuntu", "debian"
    include_recipe "tracelytics::apt"
when "redhat", "centos"
    include_recipe "tracelytics::yum"
end

# Be sure to set your access_key in an environment/role/node attribute.
template "/etc/tracelytics.conf" do
    source "etc/tracelytics.conf.erb"
end

# Install the packages
case node['platform']
when "ubuntu", "debian"
    packages = ["liboboe0", "liboboe-dev", "tracelyzer"]
when "redhat", "centos"
    packages = ["liboboe", "liboboe-devel", "tracelyzer"]
end
packages.each do |package_name|
    package package_name do
        action :install
    end
end
