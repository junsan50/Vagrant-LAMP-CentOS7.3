# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "bento/centos-7.3"

  config.vm.network "private_network", ip: "192.168.33.10"

  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--cableconnected1", "on"]
  end

  config.vm.provision "file", source: "./MariaDB.repo", destination: "/tmp/MariaDB.repo"
  config.vm.provision "shell", path: "./setup.sh"

  config.vm.provision "reboot", type: "shell", run: "always" do |s|
    s.inline = "sudo systemctl restart httpd"
  end
end
