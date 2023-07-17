BOX_COUNT = 1
CPU_PER_BOX = 2
MEMORY_PER_BOX = 4096
IMAGE = "basebox_k3d_debian-11"

Vagrant.configure("2") do |config|
  (1..BOX_COUNT).each do |i|
    config.vm.define "k3d-#{i}" do |k3ds|
      k3ds.vm.box = IMAGE
      k3ds.vm.provider :virtualbox do |v|
        v.linked_clone = true
        v.memory = MEMORY_PER_BOX
        v.cpus = CPU_PER_BOX
      end
      k3ds.vm.hostname = "k3d#{i}"

      #### Enable the folowing, if you want to shell into the box from another machine
      #### In thise case, add your public key to /home/vagrant/.ssh/authorized_keys by enabling the command abit further below
      k3ds.vm.network "forwarded_port", guest: 22, host: 12222, protocol: "tcp"
      k3ds.vm.network  :private_network, ip: "192.168.1.#{i+9}"
	  k3ds.vm.provision "file", source: "./ssh", destination: "~/ssh"
	  k3ds.vm.provision "file", source: "./scripts", destination: "~/scripts"
      k3ds.vm.provision "shell", path: "./setup.sh" do |s|
	    s.args = ["cluster"]
	  end
    end
  end
end
