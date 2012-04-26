include_recipe "apt"

remote_file "/tmp/tracelytics.key" do
    source "https://apt.tracelytics.com/tracelytics-apt-key.pub"
    mode "0644"
    checksum "b876cb2a74f343803ac21282ebe279b38b0c87fb961332a965c5640abaca3688"
end

execute "add-apt-key" do
    command "apt-key add /tmp/tracelytics.key"
    action :run
    not_if "apt-key list | grep 03311F21"
end

apt_repository "tracelytics" do
    uri "http://apt.tracelytics.com/"
    components ["main"]
    distribution node[:lsb][:codename]
end

