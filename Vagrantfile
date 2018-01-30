# -*- mode: ruby -*-
# vi: set ft=ruby :

BOX_IMAGE = "ubuntu/xenial64"
HOSTNAME = "kata-dev"
BRIDGE_IF = "enp6s0"
#BRIDGE_IF = "wlp5s0"

GO_VER = "1.9.3"

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  config.vm.box = BOX_IMAGE
  config.vm.box_check_update = false
  config.vbguest.auto_update = false
  config.vm.hostname = HOSTNAME 
  config.hostmanager.enabled = true
  config.hostmanager.manage_guest = true
  config.hostmanager.manage_host = true
  config.hostmanager.ignore_private_ip = false

  config.hostmanager.ip_resolver = proc do |machine|
    result = ""
    machine.communicate.execute("hostname -I | cut -d ' ' -f 2") do |type, data|
      result << data if type == :stdout
    end
    ip = result.split("\n").first[/(\d+\.\d+\.\d+\.\d+)/, 1]
  end

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # NOTE: This will enable public access to the opened port
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine and only allow access
  # via 127.0.0.1 to disable public access
  # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  config.vm.network "public_network", type: "dhcp", :bridge => BRIDGE_IF
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
    vb.memory = "1024"
    vb.cpus = "1"
  end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  config.vm.provision "shell", inline: <<-SHELL
    apt-get -y install apt-transport-https ca-certificates wget software-properties-common
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    sh -c "echo 'deb http://download.opensuse.org/repositories/home:/clearcontainers:/clear-containers-3/xUbuntu_$(lsb_release -rs)/ /' >> /etc/apt/sources.list.d/clear-containers.list"
    wget -qO - http://download.opensuse.org/repositories/home:/clearcontainers:/clear-containers-3/xUbuntu_$(lsb_release -rs)/Release.key | sudo apt-key add -
    wget -qO - https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    if [ ! -f /tmp/go#{GO_VER}.linux-amd64.tar.gz ]
    then
      wget https://dl.google.com/go/go#{GO_VER}.linux-amd64.tar.gz -O /tmp/go#{GO_VER}.linux-amd64.tar.gz
      tar -C /usr/local -xzf /tmp/go#{GO_VER}.linux-amd64.tar.gz
    fi

    apt-get update && apt-get -y full-upgrade 
    apt-get -y install docker-ce make gcc cc-runtime cc-proxy cc-shim
    systemctl enable docker.service
    systemctl restart docker.service

    mkdir -p /root/go/{bin,pkg,src}
    echo "export GOPATH=$HOME/go" >> /root/.bashrc
    echo "export KATA_RUNTIME=cc" >> /root/.bashrc
    echo "export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin" >> /etc/profile
    echo "export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin" >> /root/.bashrc

  SHELL
end
