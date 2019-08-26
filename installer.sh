#!/bin/bash

list=(fs-repo-migrations go-ipfs gx gx-go ipfs-cluster-ctl ipfs-cluster-service ipfs-ds-convert ipfs-pack ipfs-see-all ipfs-update ipget)

getmainrepo() {
  case "$1" in
    ipfs-cluster-ctl|ipfs-cluster-service)
      mainrepo="ipfs"
      subrepo="ipfs-cluster"
      ;;
    fs-repo-migrations|go-ipfs|ipfs-pack|ipfs-update|ipget)
      mainrepo="ipfs"
      ;;
    gx|gx-go|ipfs-see-all)
      mainrepo="whyrusleeping"
      ;;
  esac
}

non_break_space=" " #char code 160

# SYSTEM TYPE
  getarch() {
    if uname -m | grep 'x86_64' > /dev/null; then
      echo "amd64"
      return 0
    fi
    if uname -m | grep '^arm' > /dev/null; then
      echo "arm"
      return 0
    else
      echo "386"
    fi
  }

  getos() {
    uname -s | tr '[:upper:]' '[:lower:]'
  }

  which() {
    for p in /bin /usr/bin /usr/local/bin; do
      if [ -x $p/$1 ]; then
        echo $p/$1
        return 0
      fi
    done
    command -v $@
    return $?
  }

# CACHE
  cachefile="$HOME/.cache/dist.ipfs.io-installer"
  mkdir -p $(dirname $cachefile)
  read_cache() {
    if [ ! -f $cachefile ]; then echo "#dist.ipfs.io-installer script cache - DO NOT EDIT!" > $cachefile;fi
    cache=$(cat $cachefile 2> /dev/null)
  }
  read_cache
  updatedata() {
    local r=$(echo "$cache" | grep "^$1=")
    echo "$cache" | grep "^$1=" 2> /dev/null > /dev/null
    ex=$?
    if [ $ex -ne 0 ]; then
      :
    else
      sed -i "/^$1=/d" -i $cachefile
    fi
    read_cache
    cache="$cache
$1=$2"
    echo "$cache" > $cachefile
  }

  getdata() {
    local r=$(echo "$cache" | grep "^$1=")
    echo ${r//"$1="/""}
  }

  getversions() {
    getdata versions_$1
  }

# BASIC
  join_by() { local IFS="$1"; shift; echo "$*"; }

  log() {
    echo $(date +"%H:%M:%S") "$@"
  }

  is_brokenver() {
    if [ "$1" == "fs-repo-migrations" ]; then return 0; else return 2; fi
  }

  sudo() {
    if [ "$(whoami)" == "root" ]; then
      $@ 2>&1
    else
      $(which sudo) -v -n 2> /dev/null > /dev/null
      if [ $? -ne 0 ]; then
        $(which sudo) -v
        if [ $? -ne 0 ]; then
          sudo $@
          return 0
        else
          log "Sudo access granted"
          echo ${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}${non_break_space}
        fi
      fi
      $(which sudo) -n -- $@ 2>&1
    fi
  }


# GET
  buildurl() {
    if curl --silent -f http://localhost:8080/ipns/dist.ipfs.io/ > /dev/null 2> /dev/null; then
      echo http://localhost:8080/ipns/dist.ipfs.io/$1
    else
      echo https://dist.ipfs.io/$1
    fi
  }
  geturl() {
    curl --silent -f $(buildurl $1)
  }

  getbin() {
    if [ "x$1" == "xgo-ipfs" ]; then b="ipfs"; else b=$1; fi
  }

  isinstalled() {
    getbin $1
    [ -x "/usr/local/bin/$b" ] && return 0
    return 1
  }

  getversion_() {
    getbin $1
    local r=$($b $2 2> /dev/null | grep "[0-9][0-9.]*[0-9a-z-]*" -o)
    echo $r
  }

  getversion() {
    for c in -v version; do
      local r=$(getversion_ $1 $c)
      [ "x$r" != "x" ] && echo $r && return 0
    done
    echo "N/A"
  }

  getversion2() {
    for c in -v version; do
      local r=$(getversion_ $1 $c)
      [ "x$r" != "x" ] && echo v$r && return 0
    done
    echo "N/A"
  }

quit_app() {
  echo "Quitting..." | dialog --progressbox "dist.ipfs.io_Installer" 7 30
  exit $1
}

quit_with_error() {
  echo "ERROR: $1
The Application will now exit..." | dialog --progressbox "dist.ipfs.io_Installer" 10 75
  exit 2
}

dialog_unsafe() {
  /usr/bin/dialog --backtitle "dist.ipfs.io Installer" $*
}

dialog() {
  t="/tmp/$RANDOM"
  args="$*"
  args=${args//"_"/"$non_break_space"}
  dialog_unsafe $args 2> $t
  local ex=$?
  if [ $ex -ne 0 ] && [ $ex -ne 1 ] && [ $ex -ne 2 ]; then
    cat $t
    log "[dialog] $*"
    log "[exit with $ex]"
    exit $ex
  fi
  res=$(cat $t)
  rm $t
  return $ex
}

install_version_() {
  soft=$1
  targetv="$2"
  target="$3"
  sver="$4"
  sverv="$5"
  getbin $soft
  log "Installing $soft $targetv..."

  arch=$(getarch)
  os=$(getos)

  log "Checking for compatibility (arch: $arch, os: $os)..."

  compatible=$(geturl $soft/$targetv/results)
  if echo "$compatible" | grep ", $os, $arch,"  > /dev/null; then

    log "Downloading binary..."
    tmpd="/tmp/$soft.download.$RANDOM"
    tmpf="$tmpd.tar.gz"

    wget -qq $(buildurl $soft/$targetv/${soft}_${targetv}_$os-$arch.tar.gz) -O $tmpf
    ex=$?
    if [ $ex -ne 0 ]; then
      log "Binary download failed!"
      return $ex
    fi

    log "Extracting Binary..."
    mkdir -p $tmpd
    cd $tmpd
    tar xvfz $tmpf

    cd $soft
    log "Installing Binary..."

    if [ -f ./install.sh ]; then
      log "Running install.sh"
      if [ "$6" == "cli" ]; then
        bash ./install.sh
      else
        sudo bash ./install.sh
      fi
      echo
      if [ $? -ne 0 ]; then
        log "FAILED!"
      fi
    else
      target="/usr/local/bin/$b"
      if [ "$6" == "cli" ]; then
        mv $b $target
      else
        sudo mv $b $target
      fi
      if [ $? -ne 0 ]; then
        log "FAILED!"
      else
        log "Installed $b to $target"
      fi
    fi

    log "Cleaning up..."
    cd
    rm -rf $tmpd $tmpf
    log "DONE!"
    return 0
  else
    log "Software is incompatible"
    sup=${compatible//"github.com/ipfs/$b, "/""}
    log "Supported versions:
$sup"
    return 2
  fi

  #IFS=', ' read -r -a array <<< "$string"
}

install_version() {
  if [ "$1" == "go-ipfs" ]; then
    t="It is recommended to upgrade go-ipfs with ipfs-update\nAre you sure want to continue?"
    dialog --yesno ${t//" "/"_"} 10 70
    if [ $? -ne 0 ]; then
      return 1;
    fi
  fi
  install_version_ $1 $2 $3 $4 $5 | dialog_unsafe --timeout 5 --programbox Install${non_break_space}$1${non_break_space}$2... 40 120 2> /dev/null
}

select_version() {
  title="$1"
  soft="$2"
  res=""
  for v in $svers; do
    cver=${v/"v"/""}
    ap=""
    if [ "$cver" == "$slatest" ]; then
      ap="${ap}_(latest)"
    fi
    if [ "$cver" == "$sver" ]; then
      ap="${ap}_(current)"
    fi
    res="${soft}_$cver $v$ap $res"
  done
  dialog --menu $title 0 0 20 $res
  if [ -z $res ]; then return 2; fi
  for v in $svers; do
    cver=${v/"v"/""}
    if [ "$res" == "${soft}${non_break_space}$cver" ]; then
      $3 $soft $v $cver $sver $sverv
      return $?
    fi
  done
  quit_with_error "Index error"
}

ipfs_upgrade() {
  (
    log "Unlocking /usr/local/bin (otherwise $HOME/.ipfs will be owned by root)"
    sudo chmod 777 /usr/local/bin
    sudo chmod 777 /usr/local/bin/ipfs

    log "Running ipfs-update"
    ipfs-update install $3

    log "Locking /usr/local/bin"
    sudo chmod 755 /usr/local/bin
    sudo chown root:root /usr/local/bin
    sudo chmod 755 /usr/local/bin/ipfs
    sudo chown root:root /usr/local/bin/ipfs
  ) | dialog_unsafe --timeout 5 --programbox Upgrade${non_break_space}$1${non_break_space}to${non_break_space}$2${non_break_space}\(with${non_break_space}ipfs-update\)... 20 80 2> /dev/null
}

ipfs_update() {
  if isinstalled ipfs-update; then
    svers=$(ipfs-update versions)
    select_version "Upgrade_go-ipfs_(with_ipfs-update)" go-ipfs "ipfs_upgrade"
  else
    t="You need to install ipfs-update first\nDo you want to do this now?"
    dialog --yesno ${t//" "/"$non_break_space"} 10 70
    if [ $? -ne 0 ]; then
      return 1
    else
      getinfo ipfs-update
      getbin ipfs-update
      select_version "Install_ipfs-update" ipfs-update "install_version"
      if [ $? -ne 0 ]; then
        return 2
      else
        ipfs_update
      fi
    fi
  fi
}

remove_soft() {
  soft="$1"
  getbin $soft
  pa="/usr/local/bin/$b"
  if [ ! -e $pa ]; then quit_with_error "Binary does not exist!"; fi
  t="This will remove $pa\nAre you sure want to continue?"
  dialog --yesno ${t//" "/"$non_break_space"} 10 70
  if [ $? -ne 0 ]; then
    return 1
  else
    (
    sleep .1s
    log "Remove $pa..."
    sudo rm -v $pa
    ) | dialog_unsafe --timeout 5 --programbox Remove${non_break_space}$1... 20 80 2> /dev/null
    return 0
  fi
}

show_changelog() {
  ch="/tmp/$RANDOM.$1.md"
  dialog --infobox "Loading_changelog!" 5 40
  subrepo="$1"
  getmainrepo $1
  wget -qq https://raw.githubusercontent.com/$mainrepo/$subrepo/$2/CHANGELOG.md -O $ch
  if [ $? -ne 0 ]; then
    sleep 1s | dialog --infobox "Failed_to_load_changelog!" 5 40
    rm -f $ch
  else
    clear
    dialog --textbox $ch $(expr $(tput lines) - 10 ) $(expr $(tput cols) - 10 )
    rm $ch
    echo -n "Loading..."
  fi
}

prog_menu() {
  local soft=$1
  getbin $soft
  getinfo $soft
  res=()
  if isinstalled $soft; then
    if is_brokenver $soft; then
      res+=("Installed" "Unknown_Version")
    else
      res+=("Current_Version:" $sver)
    fi
    res+=("Latest_Version:" $slatest)
    if [ "$b" == "ipfs" ]; then
      res+=("Upgrade_with_ipfs-update..." "Will_upgrade_go-ipfs_safely_(recommended)");
    fi
    res+=("Change_Version..." "Upgrade_or_downgrade_$soft")
    res+=("Remove_$soft..." "Will_remove_the_binary_(data_will_be_kept)")
  else
    res+=("Install..." "Download_and_install_${soft}_to_/usr/local/bin/$b")
  fi
  res+=("About..." "https://dist.ipfs.io/#$soft")
  res+=("Changelog..." "List_all_changes_made...")
  dialog --menu $soft 0 0 10 ${res[@]}
  if [ -z $res ]; then mainmenu; else
    case $res in
      Changelog*)
        select_version "Changelog_for" $soft "show_changelog"
        prog_menu $soft
        ;;
      Change*)
        select_version "Change_Version_of_$soft" $soft "install_version"
        prog_menu $soft
        ;;
      Remove*)
        remove_soft $soft
        if [ $? -ne 0 ]; then prog_menu $soft; else mainmenu; fi
        ;;
      Install*)
        select_version "Installing_$soft" $soft "install_version"
        prog_menu $soft
        ;;
      About*)
        echo "Opening https://dist.ipfs.io/#$soft in browser..."
        x-www-browser "https://dist.ipfs.io/#$soft"
        prog_menu $soft
        ;;
      Upgrade*)
        ipfs_update
        prog_menu $soft
        ;;
      *)
        prog_menu $soft
        ;;
    esac
  fi
}

getinfo() {
  soft=$1
  sver=$(getversion $soft)
  sverv=$(getversion2 $soft)
  svers=$(getversions $soft)
  slatestv=$(join_by "
" $svers | tail -n 1)
  [ -z $slatestv ] && [ "x$2" == "xagain" ] && quit_with_error "No valid version index for $soft was found!
Try cleaning/updating the cache
(Hint: $cachefile)"
  if [ -z $slatestv ]; then
    [ -z $iscli ] && fetchlist
    [ "x$iscli" == "xtrue" ] && fetchlist_
    updatedata lastscan $(date +%s)
    getinfo $1 again
    return $?
  fi
  slatest=${slatestv/"v"/""}
}

mainmenu() {
  res=()
  for soft in ${list[@]}; do
    t=""
    if isinstalled $soft; then
      getinfo $soft
      if [ "$sver" == "N/A" ] || is_brokenver $soft; then
        t="Installed,______Latest_$slatest"
      else
        if [ "x$sver" != "x$slatest" ]; then ap="_(Update_available!)"; else ap=""; fi
        t="Current:_${sver},_Latest:_$slatest$ap"
      fi
    else
      t="Not_installed"
    fi
    res+=($soft)
    res+=($t)
  done
  dialog --help-button --help-label "Refresh_Cache" --menu "dist.ipfs.io" 0 0 10 ${res[@]}

  if [ -z $res ]; then
    quit_app
  else
    if [[ "$res" == HELP* ]]; then
      mainloop "f"
    else
      prog_menu $res
    fi
  fi
}


fetchlist_() {
  log "Fetching version lists..."
  for soft in ${list[@]}; do
    log "$soft"
    vers=$(geturl $soft/versions)
    [ $? -ne 0 ] && echo "ERROR: Failed to download version list for $soft!" && exit $?
    updatedata versions_$soft "$(echo $vers)"
  done
  log "Done!"
}

fetchlist() {
  tmpfile="/tmp/dist-tail-$RANDOM"
  touch $tmpfile
  fetchlist_ | dialog_unsafe --timeout 1 --programbox Update${non_break_space}Cache... 20 50 2> /dev/null
}

mainloop() {
  echo "Loading..." | dialog --progressbox "dist.ipfs.io_Installer" 7 30
  local last=$(getdata lastscan)
  if [ "x$last" == "x" ] || [ "x$1" == "xf" ]; then
    fetchlist
    updatedata lastscan $(date +%s)
  fi
  mainmenu
  quit_with_error "Internal Error" # if something exited unexpected
}

#cli

cli_error() {
  echo "ERROR: $@" 1>&2
  exit 2
}

package_valid() {
  for p in "${list[@]}"; do
    if [ "$p" == "$1" ]; then return 0; fi
  done
  return 2
}

cache_check() {
  local last=$(getdata lastscan)
  if [ "x$last" == "x" ]; then
    cli_error "Cache is empty!
Run: $0 update-cache"
  fi
}

package_validate() {
  if [ -z $1 ]; then cli_error "Missing package argument"; fi
  cache_check
  if ! package_valid $1; then
    cli_error "Package name is invalid"
  fi
  #prepare
  getinfo $1
  getbin $1
}

version_valid() {
  [ -z "$1" ] && return 0
  for v in $svers; do
    if [ "$v" == "$1" ]; then return 0; fi
  done
  return 2
}

version_validate() {
  if [ -z $2 ]; then cli_error "Missing version argument"; fi
  package_validate $1
  if ! version_valid $2; then
    cli_error "Invalid version for $1 (Is the cache up-to-date?)"
  fi
}

check_root() {
  if [ $(id -u) != "0" ]; then cli_error "Only root can do this (use sudo $0)"; fi
}

if [ -z $1 ]; then
  mainloop
else
  iscli=true
  case "$1" in
    install)
      check_root
      if [ -z $3 ]; then
        package_validate $2
        vv=$slatestv
        log "No version specifed - using latest $vv"
      else
        version_validate $2 $3
        vv=$3
      fi
      install_version_ $2 $vv ${vv/"v"/""} $sver $sverv "cli"
      ;;
    remove)
      check_root
      package_validate $2
      soft=$2
      if ! isinstalled $2; then cli_error "Not installed, not removing"; fi
      getbin $soft
      pa="/usr/local/bin/$b"
      if [ ! -e $pa ]; then cli_error "Binary does not exist!"; fi
      log "$soft is going to be removed!"
      log "$pa is the current location of $soft"
      case "$3" in
        --[yY] | --[yY][Ee] | --[yY][Ee][Ss] | -[yY] | -[yY][Ee] | -[yY][Ee][Ss] | -[fF])
          rm $pa
          log "removed $pa"
          ;;
        *)
          read -p "Sure? [y/N]" sure
          case "$sure" in
            [yY] | [yY][Ee] | [yY][Ee][Ss])
              rm $pa
              echo "removed $pa"
              ;;
            *)
              cli_error "Abort."
              ;;
          esac
      esac
      ;;
    status)
      package_validate $2
      soft=$2
      t=""
      if isinstalled $soft; then
        getinfo $soft
        if [ "$sver" == "N/A" ] || is_brokenver $soft; then
          t="Installed, Latest $slatest"
        else
          if [ "x$sver" != "x$slatest" ]; then ap=" (Update available!)"; else ap=""; fi
          t="Current: ${sver}, Latest: $slatest$ap"
        fi
      else
        t="Not installed"
      fi
      echo " - $soft: $t"
      if isinstalled $soft; then exit 0; else exit 1; fi
      ;;
    #ipfs-update
    update-cache)
      fetchlist_
      updatedata lastscan $(date +%s)
      ;;
    list)
      cache_check
      echo "Packages:"
      for soft in ${list[@]}; do
        t=""
        if isinstalled $soft; then
          getinfo $soft
          if [ "$sver" == "N/A" ] || is_brokenver $soft; then
            t="Installed, Latest $slatest"
          else
            if [ "x$sver" != "x$slatest" ]; then ap=" (Update available!)"; else ap=""; fi
            t="Current: ${sver}, Latest: $slatest$ap"
          fi
        else
          t="Not installed"
        fi
        echo " - $soft: $t"
      done
      ;;
    list-versions)
      package_validate $2
      echo "Versions:"
      res=""
      for v in $svers; do
        cver=${v/"v"/""}
        ap=""
        if [ "$cver" == "$slatest" ]; then
          ap="${ap} (latest)"
        fi
        if [ "$cver" == "$sver" ]; then
          ap="${ap} (current)"
        fi
        res=" - ${soft}_$cver $v$ap
$res"
      done
      echo "$res"
      ;;
    changelog)
      if [ -z $3 ]; then
        package_validate $2
        lookup=$slatestv
      else
        version_validate $2 $3
        lookup=$3
      fi
      ch="/tmp/$RANDOM.$1.md"
      subrepo="$2"
      getmainrepo $2
      wget -qq https://raw.githubusercontent.com/$mainrepo/$subrepo/$lookup/CHANGELOG.md -O $ch
      if [ $? -ne 0 ]; then
        cli_error "Failed to load changelog!"
        rm -f $ch
      else
        cat $ch
        rm $ch
      fi
      ;;
    about)
      package_validate $2
      case "$3" in
        -b|--browser)
          echo "Opening https://dist.ipfs.io/#$soft in browser..."
          [ -z "$DISPLAY" ] && echo "WARNING: \$DISPLAY is not set"
          x-www-browser "https://dist.ipfs.io/#$soft"
          ex=$?
          [ $ex -ne 0 ] && cli_error "Couldn't open browser: $ex"
          ;;
        *)
          echo "About $2: https://dist.ipfs.io/#$soft"
          ;;
      esac
      ;;
    gui)
      mainloop
      ;;
    *)
      echo "Usage: $0 <command> [<options>]"
      echo "Commands:"
      echo " - install <package> [<version>]"
      echo " - remove <package> [-y]"
      echo " - status <package>"
      echo " - ipfs-update <version>"
      echo " - update-cache"
      echo " - list"
      echo " - list-versions"
      echo " - changelog <package> [<version>]"
      echo " - about <package> --browser"
      echo " - gui"
      ;;
  esac
fi
