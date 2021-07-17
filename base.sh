#!/bin/sh -e

kiss_container=$(buildah from scratch)
kiss_mount=$(buildah mount $kiss_container)
kiss_chroot_uri=https://github.com/kisslinux/repo/releases/download/2021.7-6
kiss_chroot_file=kiss-chroot-2021.7-6.tar.xz
curl --location --silent --remote-name $kiss_chroot_uri/$kiss_chroot_file
curl --location --silent $kiss_chroot_uri/$kiss_chroot_file.sha256 | sha256sum -c
echo TODO: key verification
cp $kiss_chroot_file $kiss_mount/
cd $kiss_mount
tar xf $kiss_chroot_file
cd -
buildah commit $kiss_container kiss
buildah tag localhost/kiss 2021.7.6
buildah unmount $kiss_container

kiss_container=$(buildah from localhost/kiss)
kiss_mount=$(buildah mount $kiss_container)
echo running for $kiss_container
buildah run $kiss_container git clone https://github.com/kisslinux/repo /repos/official
buildah config \
  --env KISS_PATH=/repos/official/core:/repos/official/extra:/repos/offical/wayland \
  --env KISS_PROMPT=0 \
  $kiss_container
echo ERROR will happen in following command
buildah run $kiss_container kiss update
echo TODO: gpg verification
buildah run $kiss_container bash
