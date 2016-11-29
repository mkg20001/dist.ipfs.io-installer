# dist.ipfs.io-installer
Install software from dist.ipfs.io

# Install
Install this script to /usr/bin with: `sudo make install`

# GUI
If you run `bash installer.sh` without arguments it opens a GUI in the terminal (no real GUI - just `dialog`)

# Usage
```
Usage: ./installer.sh <command> [<options>]
Commands:
 - install <package> [<version>]
 - remove <package> [-y]
 - status <package>
 - ipfs-update <version>
 - update-cache
 - list
 - list-versions
 - changelog <package> [<version>]
 - about <package> --browser
 - gui
```
