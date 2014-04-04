include_recipe "apache2"

package "libapache2-mod-oboe" do
    action :install
end

template "/etc/apache2/mods-available/oboe.conf" do
    source "etc/apache2/mods-available/oboe.conf.erb"
    mode "0644"
    owner "root"
    group "root"
    action :create
    notifies :reload, "service[apache2]"
end
