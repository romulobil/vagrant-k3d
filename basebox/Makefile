build: destroy
	vagrant up
	vagrant halt
	vagrant package --output basebox_k3d_debian-11.box
	vagrant box remove basebox_k3d_debian-11 -f
	vagrant box add basebox_k3d_debian-11 basebox_k3d_debian-11.box
	rm basebox_k3d_debian-11.box
	vagrant destroy	-f
	
destroy:
	vagrant destroy -f