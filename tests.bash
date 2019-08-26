#!/bin/bash

list=(fs-repo-migrations go-ipfs gx gx-go ipfs-cluster-ctl ipfs-cluster-service ipfs-ds-convert ipfs-pack ipfs-see-all ipfs-update ipget)

arg0="./installer.sh"

prg="sudo bash $arg0"

hasfailed=0

test_fail() {
  hasfailed=1
  echo "[fail] $1"
  echo " - Expected: $2"
  echo " - Got: $3"
  echo " - $(echo $4 | grep '^ERROR:[a-zA-Z0-9_! -]*' -o)"
  echo "[cancel] exit with 2"
  exit 2
}

test_pass() {
  echo "[ok] Passed!"
}

tests() {
  echo
  echo "[test] $1 \$ installer.sh $2"
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

tests "Install go-ipfs (without cache updated)" "install go-ipfs" 2 "ERROR: Cache is empty!
Run: $arg0 update-cache"

all_cache=""

for soft in "${list[@]}"; do
  [ ! -z "$all_cache" ] && all_cache="$all_cache
"
  all_cache="$all_cache$soft"
done

tests "Update Cache" "update-cache" 0 "Fetching version lists...
$all_cache
Done!"

for soft in "${list[@]}"; do
  tests "Remove $soft (not installed)" "remove $soft" 2 "ERROR: Not installed, not removing"
  tests "Status $soft (not installed)" "status $soft" 1
  tests "Versions $soft" "list-versions $soft" 0
  ver=$(echo "$output" | tr " " "\n" | head -n 5 | tail -n 1)
  echo "Version: $soft $ver"
  tests "Install $soft (with invalid version)" "install $soft invalid" 2 "ERROR: Invalid version for $soft (Is the cache up-to-date?)"
  tests "Install $soft (without version specified)" "install $soft" 0
  tests "Install $soft" "install $soft $ver" 0
  tests "Status $soft (installed)" "status $soft" 0
  tests "Remove $soft (installed)" "remove $soft -y" 0
done

exit $hasfailed
