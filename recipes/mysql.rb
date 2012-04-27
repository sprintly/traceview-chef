cookbook_file "/root/build_mysql_deb.sh" do 
    source "build_mysql_deb.sh"
    owner "root"
    group "root"
    mode "0755"
    action :create_if_missing
end

remote_file "/root/mysql-tracelytics.diff" do
    source "http://packages.tracelytics.com/src/mysql-tracelytics.diff"
    checksum "6aef7ddd900947e40d82873669d32162ad1d88f42a8f269cafe1925e5e5be5aa"
    owner "root"
    group "root"
    action :create_if_missing
end

execute "patch_mysql_and_create_deb" do
    user "root"
    command "/root/build_mysql_deb.sh /root/mysql-tracelytics.diff"
    cwd "/root"
    action :run
    not_if "dpkg --list | grep tracelytics"
end

execute "install_libmysql_deb" do
    user "root"
    command "dpkg --install /root/libmysqlclient[0-9][0-9]_*trace*.deb"
    cwd "/root"
    action :run
    not_if "dpkg --list | grep tracelytics"
end
