#!/bin/bash

list=(fs-repo-migrations go-ipfs gx gx-go ipfs-see-all ipfs-update ipget)

prg="sudo bash ./installer.sh"

hasfailed=0

test_fail() {
  hasfailed=1
  echo "[fail] $1"
  echo "Expected: $2"
  echo "Got: $3"
}

tests() {
  echo
  echo "[test] $1"
  output=$($prg $2)
  echo "result:
$output"
  ex=$?
  pass=1
  if [ ! $ex -eq $3 ]; then test_fail ""
  if [ ! -z $4 ]; if [ "$output" != "$4" ]; then test_fail "Wrong output" $4 $output
}

for soft in "${list[@]}"; do
  tests "Install $soft" "install $soft" 0
done

exit $hasfailed
