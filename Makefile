VERSIONS = 18.04 16.04 14.04
install:
	cp installer.sh /usr/bin/ipfs-installer
	chmod 755 /usr/bin/ipfs-installer
	chown root:root /usr/bin/ipfs-installer
test:
	bash tests.bash
docker-test:
	$(foreach ver,$(VERSIONS),docker run -v $(PWD):/src ubuntu:$(ver) sh -c 'apt-get update && apt-get install make curl wget sudo -y && make -C /src test' && ) echo "OK!"
