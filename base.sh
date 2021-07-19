#!/bin/sh -e


buildah images localhost/kiss >/dev/null || {
  kiss_image_version=2021.7-7
  kiss_container=$(buildah from scratch)
  kiss_mount=$(buildah mount $kiss_container)
  kiss_chroot_uri=https://github.com/kisslinux/repo/releases/download/$kiss_image_version
  kiss_chroot_file=kiss-chroot-$kiss_image_version.tar.xz
  curl --location --silent --remote-name $kiss_chroot_uri/$kiss_chroot_file
  curl --location --silent $kiss_chroot_uri/$kiss_chroot_file.sha256 | shasum -a256 -c
  # TODO: key verification
  cp $kiss_chroot_file $kiss_mount/
  tar x -C $kiss_mount -f $kiss_chroot_file
  buildah commit $kiss_container kiss
  buildah tag localhost/kiss $kiss_image_version
  buildah unmount $kiss_container
}

kiss_version=5.4.11
buildah images localhost/kiss-$kiss_version >/dev/null || {
  kiss_container=$(buildah from localhost/kiss)
  kiss_mount=$(buildah mount $kiss_container)
  buildah run $kiss_container git clone https://github.com/kisslinux/repo /repos/official
  buildah config \
    --env KISS_PATH=/repos/official/core:/repos/official/extra:/repos/offical/wayland \
    --env KISS_PROMPT=0 \
    $kiss_container
  buildah run $kiss_container kiss update
  # TODO: gpg verification
  kiss_binary_version=$(buildah run $kiss_container kiss version)
  buildah commit $kiss_container localhost/kiss-$kiss_version
}

echo podman run localhost/kiss-$kiss_version kiss list
