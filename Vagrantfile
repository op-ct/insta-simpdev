# simp-core ISO builder VM
# ------------------------------------------------------------------------------
# Usage:
#
#    See README.md for details
#
# ------------------------------------------------------------------------------
# -*- mode: ruby
# vi: set ft=ruby :

VM_CPUS = ENV['VAGRANT_VM_CPUS'] || '8'

BASH_ENV = (
  ENV.to_h
   .select{ |k,v| k =~ /^SIMP_|^BEAKER_|^PUPPET_|^FACTER_|NO_SELINUX_DEPS|^DEBUG|^VERBOSE/ }
)

BASH_ENV_STRING = (
   BASH_ENV.map{|k,v| "#{k}=#{v}"}.join(' ')
)

Vagrant.configure('2') do |config|
  # For a complete reference of configuration options, please see the online
  # documentation at https://docs.vagrantup.com.
  config.vm.box = 'centos/7'
  config.vm.define ENV['VAGRANT_BOX_NAME'] || 'simp_builder'

  config.vm.provider 'virtualbox' do |vb|
    vb.customize ['modifyvm', :id, '--ioapic', 'on']
    vb.memory = '4096'
    vb.cpus   = VM_CPUS
  end

  # superuser provisioning
  config.vm.provision 'shell', inline: 'bash /vagrant/scripts/root/provision.sh'

  # vagrant provisioning
  config.vm.provision 'shell',
    privileged: false,
    env: BASH_ENV,
    inline: "SIMP_BUILDER_tasks=provision source /vagrant/scripts/vagrant/run_tasks.sh"

  config.vm.provision 'shell', privileged: false, inline: <<-SHELL
    cd /vagrant
    # Just run the provision step to install RVM in a separate session
    echo "Hello from Vagrantfile!"
    cd /vagrant
    #{BASH_ENV_STRING} SIMP_BUILDER_task_provision=no bash scripts/vagrant/run_tasks.sh
  SHELL
end
