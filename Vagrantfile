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

  config.vm.provision 'shell', inline: 'bash /vagrant/scripts/root/provision.sh'

  # pass on certain environment variables from the `vagrant CMD` cli to the
  # tasks running in the VM
  bash_env_string = (
    ENV
     .to_h
     .select{ |k,v| k =~ /^SIMP_.*|^BEAKER_.*|NO_SELINUX_DEPS/ }
     .map{|k,v| "#{k}=#{v}"}.join(' ')
  )

  config.vm.provision 'shell', privileged: false, inline: <<-SHELL
    cd /vagrant
    source scripts/vagrant/install_rvm.sh
    source scripts/vagrant/setup_aria2c.sh

    cd /vagrant

    # download ISOs if they are not already present
    # -------
    # NOTE: speed things up
    #{bash_env_string} bash scripts/vagrant/get_isos.sh centos7 centos6

    # Build simp from those ISOs
    #{bash_env_string} bash scripts/vagrant/build_iso.sh downloads/isos/*.iso
  SHELL
end
