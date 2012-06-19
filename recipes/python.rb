include_recipe "python"

python_pip "oboe" do
    action :install
    options "--extra-index-url=http://pypi.tracelytics.com -U"
    version "0.5.1"
end
