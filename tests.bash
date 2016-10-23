#!/bin/bash

list=(fs-repo-migrations go-ipfs gx gx-go ipfs-see-all ipfs-update ipget)

prg="sudo bash ./installer.sh"

hasfailed=0

test_fail() {
  hasfailed=1
  echo "[fail] $1"
  echo " - Expected: $2"
  echo " - Got: $3"
  echo " - $(echo $4 | grep '^ERROR:[a-zA-Z0-9_! -]*' -o)"
}

test_pass() {
  echo "[ok] Passed!"
}

tests() {
  echo
  echo "[test] $1"
  output=$($prg $2 2>&1)
  ex=$?
  echo "$output"
  output=$(echo "$output" | sed -e 's#^[0-9]*:[0-9]*:[0-9]* ##')
  if [ ! $ex -eq $3 ]; then test_fail "Wrong exit code" $3 $ex "$output"; return 2; fi
  if [ ! -z "$4" ]; then
    if [ "$output" != "$4" ]; then test_fail "Wrong output" "$4" "$output" "$output"; return 2; fi
  fi
  test_pass
}

#echo " - list"
#echo " - update-cache"
#echo " - list-versions"

#echo " - install <package> <version>" yes
#echo " - status <package>"
#echo " - remove <package>"
#echo " - ipfs-update <version>"
#echo " - changelog <package> [<version>]"
#echo " - about <package> --browser"
#echo " - gui" N/A



tests "Update Cache" "update-cache" 0 "Fetching version lists...
fs-repo-migrations
go-ipfs
gx
gx-go
ipfs-see-all
ipfs-update
ipget
Done!"

tests ""

for soft in "${list[@]}"; do
  tests "Status $soft (not installed)" "status $soft" 1
  tests "Versions $soft" "list-versions $soft" 0
  ver=$(echo "$output" | grep "v[0-9.]*" -o | head -n 1)
  echo "Version: $soft $ver"
  tests "Install $soft" "install $soft $ver" 0
  tests "Status $soft (installed)" "status $soft" 0
done

exit $hasfailed
