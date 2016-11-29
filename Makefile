install:
	cp installer.sh /usr/bin/ipfs-installer
	chmod 755 /usr/bin/ipfs-installer
	chown root:root /usr/bin/ipfs-installer
test:
	bash tests.bash
