include_recipe "apache2"

package "libapache2-mod-oboe" do
    action :install
end

tracing_mode = "always"
sampling_rate = "300000"

if node.key?("traceview")
    tracing_mode = node["traceview"].fetch("tracing_mode", tracing_mode)
    sampling_rate = node["traceview"].fetch("sampling_rate", sampling_rate)
end

template "/etc/apache2/mods-available/oboe.conf" do
    source "etc/apache2/mods-available/oboe.conf.erb"
    mode "0644"
    owner "root"
    group "root"
    variables(
        :tracing_mode => tracing_mode,
        :sampling_rate => sampling_rate
    )
    action :create
    notifies :reload, "service[apache2]"
end
