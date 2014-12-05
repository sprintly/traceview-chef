include_recipe "apt"

remote_file "#{Chef::Config[:file_cache_path]}/traceview.key" do
    source "https://apt.tracelytics.com/tracelytics-apt-key.pub"
    mode "0644"
    checksum "6c560210a2265cba05edcba6629b8e3383db414bab94a8c89d1369ad5b56691e"
end

execute "add-apt-key" do
    command "apt-key add #{Chef::Config[:file_cache_path]}/traceview.key"
    action :run
    not_if "apt-key list | grep E04AD2E4"
end

apt_repository "traceview" do
    uri "http://apt.tracelytics.com/"
    components ["main"]
    distribution node['lsb']['codename']
end
