require 'spec_helper'

describe 'tracelytics::apache2' do
  let(:chef_run) {
    ChefSpec::Runner.new do |node|
      node.set['lsb']['codename'] = 'ubuntu'
    end.converge(described_recipe)
  }

  before(:each) do
    stub_command("apt-key list | grep 03311F21").and_return(true)
  end

  it('should install libapache2-mod-oboe') do
    expect(chef_run).to install_package('libapache2-mod-oboe')
  end

  it('should create oboe.conf') do
    expect(chef_run).to create_template('/etc/apache2/mods-available/oboe.conf').with(
      owner: "root",
      group: "root"
    )
  end

  it('should reload apache2') do
    resource = chef_run.template('/etc/apache2/mods-available/oboe.conf')
    expect(resource).to notify('service[apache2]').to(:reload)
  end
end
