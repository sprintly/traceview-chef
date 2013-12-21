require 'spec_helper'

describe 'tracelytics::apt' do
  let(:chef_run) {
    ChefSpec::Runner.new do |node|
      node.set['lsb']['codename'] = 'ubuntu'
    end.converge(described_recipe)
  }

  before(:each) do
    stub_command("apt-key list | grep 03311F21").and_return(true)
  end
 
  it('should fetch the APT key') do
    tmp_file = "#{Chef::Config[:file_cache_path]}/tracelytics.key"
    expect(chef_run).to create_remote_file(tmp_file)
  end
end
