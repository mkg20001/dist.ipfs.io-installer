test:
	git clone https://github.com/sstephenson/bats.git
	cd bats;sudo ./install.sh /usr/local
	bats test.sh
