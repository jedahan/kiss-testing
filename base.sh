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
echo WOMP WOMP
echo TODO: gpg verification
buildah run $kiss_container bash

#RUN sed -i "s/\/dev\/tty/\/dev\/null/g" /sbin/kiss
#RUN kiss build gnupg1 && kiss install gnupg1
#RUN gpg --keyserver keys.gnupg.net --recv-key 46D62DD9F1DE636E \
#  || gpg --keyserver pgp.mit.edu --recv-key 46D62DD9F1DE636E
#RUN echo trusted-key 0x46d62dd9f1de636e >> /root/.gnupg/gpg.conf
#WORKDIR /usr/repos/official
#RUN git config merge.verifySignatures true
