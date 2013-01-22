majorver = node['platform_version'].to_i.to_s
arch = node['kernel']['machine']

yum_key "RPM-GPG-KEY-tracelytics" do
    url "https://yum.tracelytics.com/RPM-GPG-KEY-tracelytics"
    action :add
end

yum_repository "tracelytics" do
    url "http://yum.tracelytics.com/#{majorver}/#{arch}"
    key "RPM-GPG-KEY-tracelytics"
    description "Tracelytics repository"
    action :add
end
