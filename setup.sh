#!/bin/bash

. .rc

ckroot

while [[ "$1" ]]; do
	case "$1" in
	-a | --arch) [ -z "$2" ] && argerr "$1" || arch="$2" ;;
	-m | --mirror) [ -z "$2" ] && argerr "$1" || mirror="$2" ;;
	-b | --branch) [ -z "$2" ] && argerr "$1" || branch="$2" ;;
	-d | --builddir) [ -z "$2" ] && argerr "$1" || builddir="$2" ;;
	-p | --pkglist) [ -z "$2" ] && argerr "$1" || pkglist="$2" ;;
	esac
	shift
	shift
done

mkdir -p build dist
# tar -C build -xzvf build.tar.gz >/dev/null 2>&1 || cmderr

[ -z "$mirror" ] && read -p "Enter mirror (default: https://dl-cdn.alpinelinux.org/alpine): " mirror
mirror=${mirror:-"https://dl-cdn.alpinelinux.org/alpine"}

[ -z "$branch" ] && read -p "Enter branch (default: latest-stable): " branch
branch=${branch:-latest-stable}

[ -z "$arch" ] && read -p "Enter architecture: (default: x86): " arch
arch=${arch:-x86}

builddir=${builddir:-./build}
echo "Build directory is $builddir"

pkglist=${pkglist:-./pkglist.txt}
echo "Using package list $pkglist"

apk --arch "$arch" -X "$(cat apk/repositories)" -X "$mirror/$branch/main/" -X "$mirror/$branch/community/" -U --allow-untrusted --root "$builddir"/ --initdb add $(tr "\n" " " <"$pkglist") || cmderr

cp chroot.sh "$builddir"/

chroot "$builddir"/ /chroot.sh || cmderr

cp -r gearlock/src/* "$builddir"/
rm -rf "$builddir"/chroot.sh "$builddir"/bin "$builddir"/lib "$builddir"/sbin "$builddir"/usr/sbin
ln -s usr/lib "$builddir"/lib
ln -s usr/bin "$builddir"/bin
ln -s usr/bin "$builddir"/sbin
ln -s bin "$builddir"/usr/sbin


