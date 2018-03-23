# simp-core ISO builder VM
# ------------------------------------------------------------------------------
# Usage
#
#   vagrant up
#
# ENV variables:
#
#   VAGRANT_VM_CPUS    number of CPUs available to the VM (default: 8)
#   VAGRANT_VBOX_NAME  alternate vagrant name for VM (default: simp_builder)
#
# Some ENV variables are passed through to the build:
#
#   SIMP_*
#   BEAKER_*
#   *NO_SELINUX_DEPS*
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


  config.vm.provision 'shell', inline: <<-SHELL
    yum install --enablerepo=extras -y docker vim-enhanced git libicu-devel \
      rpm-build epel-release
    yum install --enablerepo=epel -y aria2 elinks haveged

    # enable HAVEGED
    systemctl start haveged
    systemctl enable haveged

    # Install docker
    # You can also append `-G vagrant` to `OPTIONS=` in /etc/sysconfig/docker
    cat <<DOCKAH > /etc/docker/daemon.json
{
  "live-restore": true,
  "group": "vagrant"
}
DOCKAH
    # man docker-storage-setup
    # https://bugzilla.redhat.com/show_bug.cgi?id=1316210
    echo 'EXTRA_STORAGE_OPTIONS="--storage-opt overlay2.override_kernel_check=true"' >> /etc/sysconfig/docker-storage-setup
    container-storage-setup
    systemctl start docker
    systemctl enable docker

    chown -R vagrant /vagrant # TODO: why is this needed?
    ls -lartZ /var/run/docker.sock
  SHELL


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

    gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
    [ -f install_rvm.sh ] || curl -sSL https://get.rvm.io > install_rvm.sh
    bash install_rvm.sh stable '--with-default-gems=beaker rake'
    source /home/vagrant/.rvm/scripts/rvm
    rvm install --disable-binary ruby-2.1.9
    gem install bundler --no-ri --no-rdoc

    cd /vagrant
    [[ -f Gemfile ]] && bundle

    # Aria for speedy downloads
    mkdir -p .aria2
    cat <<ARIA > .aria2/aria2.conf
continue
dir=/vagrant
file-allocation=none
input-file=/vagrant/.aria2/input.conf
log-level=warn
max-connection-per-server=1
min-split-size=5M
server-stat-of=/vagrant/.aria2/server-stats
server-stat-if=/vagrant/.aria2/server-stats
uri-selector=feedback
max-concurrent-downloads=5
ARIA

    cd /vagrant
    # download ISOs if they are not already present
    #{bash_env_string} bash get_isos.sh centos7 centos6

    # Build simp from those ISOs
    #{bash_env_string} bash build_iso.sh downloads/isos/*.iso

    ###    #{bash_env_string} bundle exec rake beaker:suites[rpm_docker]
  SHELL
end
