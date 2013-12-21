require 'spec_helper'

describe 'tracelytics::default' do
  let(:chef_run) {
    ChefSpec::Runner.new do |node|
      node.set['lsb']['codename'] = 'ubuntu'
    end.converge(described_recipe)
  }

  before(:each) do
    stub_command("apt-key list | grep 03311F21").and_return(true)
  end
 
  it 'should create a tracelytics.conf' do
    expect(chef_run).to render_file('/etc/tracelytics.conf')
  end

  %w(liboboe0 liboboe-dev tracelyzer).each do |package_name| 
    it "should install #{package_name}" do
      expect(chef_run).to install_package(package_name)
    end
  end
end
