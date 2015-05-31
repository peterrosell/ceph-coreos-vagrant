# -*- mode: ruby -*-
# # vi: set ft=ruby :

require 'fileutils'

Vagrant.require_version ">= 1.6.0"

CLOUD_CONFIG_PATH = File.join(File.dirname(__FILE__), "user-data")
CONFIG = File.join(File.dirname(__FILE__), "config.rb")

# Defaults for config options defined in CONFIG
$num_instances = 1
$update_channel = "stable"
$enable_serial_logging = false
$vb_gui = false
$vb_memory = 1024
$vb_cpus = 1
COREOS_VERSION = "444.0.0"
NETWORK_BASE = "172.21.13"
ADDITIONAL_DISK_PATH = "extra_disks"
# Size in Megabytes
$size_of_extra_disk = 12132

# Attempt to apply the deprecated environment variable NUM_INSTANCES to
# $num_instances while allowing config.rb to override it
if ENV["NUM_INSTANCES"].to_i > 0 && ENV["NUM_INSTANCES"]
  $num_instances = ENV["NUM_INSTANCES"].to_i
end

if File.exist?(CONFIG)
  require CONFIG
end

Vagrant.configure("2") do |config|
  config.vm.box = "coreos-%s" % $update_channel
  config.vm.box_version = ">= 444.5.0"
  config.vm.box_url = "http://%s.release.core-os.net/amd64-usr/current/coreos_production_vagrant.json" % $update_channel

  config.vm.provider :vmware_fusion do |vb, override|
    override.vm.box_url = "http://%s.release.core-os.net/amd64-usr/current/coreos_production_vagrant_vmware_fusion.json" % $update_channel
  end

  config.vm.provider :virtualbox do |v|
    # On VirtualBox, we don't have guest additions or a functional vboxsf
    # in CoreOS, so tell Vagrant that so it can be smarter.
    v.check_guest_additions = false
    v.functional_vboxsf     = false
  end

  # plugin conflict
  if Vagrant.has_plugin?("vagrant-vbguest") then
    config.vbguest.auto_update = false
  end

  (1..$num_instances).each do |i|
    config.vm.define vm_name = "core-%02d" % i do |config|
      config.vm.hostname = vm_name

      if $enable_serial_logging
        logdir = File.join(File.dirname(__FILE__), "log")
        FileUtils.mkdir_p(logdir)

        serialFile = File.join(logdir, "%s-serial.txt" % vm_name)
        FileUtils.touch(serialFile)

        config.vm.provider :vmware_fusion do |v, override|
          v.vmx["serial0.present"] = "TRUE"
          v.vmx["serial0.fileType"] = "file"
          v.vmx["serial0.fileName"] = serialFile
          v.vmx["serial0.tryNoRxLoss"] = "FALSE"
        end

        config.vm.provider :virtualbox do |vb, override|
          vb.customize ["modifyvm", :id, "--uart1", "0x3F8", "4"]
          vb.customize ["modifyvm", :id, "--uartmode1", serialFile]
        end
      end

      if $expose_docker_tcp
        config.vm.network "forwarded_port", guest: 2375, host: ($expose_docker_tcp + i - 1), auto_correct: true
      end

#      config.vm.provider :vmware_fusion do |vb|
#        vb.gui = $vb_gui
#      end

      ip = "#{NETWORK_BASE}.#{i+100}"
      config.vm.network "private_network", ip: ip
      #, virtualbox__intnet: true

      config.vm.provider :virtualbox do |vb|
        vb.gui = $vb_gui
        vb.memory = $vb_memory
        vb.cpus = $vb_cpus
        vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
        vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
#        vb.customize ["modifyvm", :id, "--nictype1", "virtio"]

        unless File.exist?("#{ADDITIONAL_DISK_PATH}/server#{i}a.vdi")
          vb.customize ["storagectl", :id, "--add", "sata", "--name", "SATA Controller" , "--portcount", 3, "--hostiocache", "on"]

          vb.customize ['createhd', '--filename', "#{ADDITIONAL_DISK_PATH}/server#{i}a.vdi", '--size', $size_of_extra_disk]
          vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 1, '--device', 0, 
          '--type', 'hdd', '--setuuid', "#{i}a000000-b8cf-457e-9df4-e3f3f26d1e11",
          '--medium', "#{ADDITIONAL_DISK_PATH}/server#{i}a.vdi"]
        end
        unless File.exist?("#{ADDITIONAL_DISK_PATH}/server#{i}b.vdi")
          vb.customize ['createhd', '--filename', "#{ADDITIONAL_DISK_PATH}/server#{i}b.vdi", '--size', $size_of_extra_disk]
          vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 2, '--device', 0, 
          '--type', 'hdd', '--setuuid', "#{i}b000000-b8cf-457e-9df4-e3f3f26d1e11",
          '--medium', "#{ADDITIONAL_DISK_PATH}/server#{i}b.vdi"]
        end
        unless File.exist?("#{ADDITIONAL_DISK_PATH}/server#{i}c.vdi")
          vb.customize ['createhd', '--filename', "#{ADDITIONAL_DISK_PATH}/server#{i}c.vdi", '--size', $size_of_extra_disk]
          vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 3, '--device', 0, 
          '--type', 'hdd', '--setuuid', "#{i}c000000-b8cf-457e-9df4-e3f3f26d1e11",
          '--medium', "#{ADDITIONAL_DISK_PATH}/server#{i}c.vdi"]
        end
      end

      # Uncomment below to enable NFS for sharing the host machine into the coreos-vagrant VM.
      #config.vm.synced_folder ".", "/home/core/share", id: "core", :nfs => true, :mount_options => ['nolock,vers=3,udp']

#      if File.exist?(CLOUD_CONFIG_PATH)-#{i}
        config.vm.provision :file, :source => "ln_disk.sh", :destination => "/tmp/ln_disk.sh"
        config.vm.provision :shell, :inline => "chmod +x /tmp/ln_disk.sh", :privileged => true

        config.vm.provision :file, :source => "#{CLOUD_CONFIG_PATH}-#{i}", :destination => "/tmp/vagrantfile-user-data"
        config.vm.provision :shell, :inline => "mv /tmp/vagrantfile-user-data /var/lib/coreos-vagrant/", :privileged => true
#      end
      config.vm.provision :shell, :inline => "mkdir -p /disks/logical/host", :privileged => true
    end
  end
end