#!/bin/bash

list=(fs-repo-migrations go-ipfs gx gx-go ipfs-see-all ipfs-update ipget)

prg="sudo bash ./installer.sh"

for soft in "${list[@]}"; do
  @test "install $soft" {
    run $prg
  }
done