#!/bin/bash

set -e
set -x

mkdir ~/privoxy && cd ~/privoxy

BASE=`pwd`
SRC=$BASE/src
WGET="wget --prefer-family=IPv4"
DEST=$BASE/opt
CC=arm-linux-musleabi-gcc
CXX=arm-linux-musleabi-g++
LDFLAGS="-L$DEST/lib"
CPPFLAGS="-I$DEST/include"
MAKE="make -j`nproc`"
CONFIGURE="./configure --prefix=/opt --host=arm-linux"
PATCHES=$(readlink -f $(dirname ${BASH_SOURCE[0]}))/patches
mkdir -p $SRC

######## ####################################################################
# ZLIB # ####################################################################
######## ####################################################################

mkdir $SRC/zlib && cd $SRC/zlib
$WGET http://zlib.net/zlib-1.2.8.tar.gz
tar zxvf zlib-1.2.8.tar.gz
cd zlib-1.2.8

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CROSS_PREFIX=arm-linux-musleabi- \
./configure \
--prefix=/opt

$MAKE
make install DESTDIR=$BASE

######## ####################################################################
# PCRE # ####################################################################
######## ####################################################################

mkdir $SRC/pcre && cd $SRC/pcre
$WGET ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.36.tar.gz
tar zxvf pcre-8.36.tar.gz
cd pcre-8.36

CC=$CC \
CXX=$CXX \
LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
$CONFIGURE \
--without-python

$MAKE
make install DESTDIR=$BASE

########### #################################################################
# PRIVOXY # #################################################################
########### #################################################################

mkdir $SRC/privoxy && cd $SRC/privoxy
$WGET http://downloads.sourceforge.net/project/ijbswa/Sources/3.0.22%20%28stable%29/privoxy-3.0.22-stable-src.tar.gz
tar zxvf privoxy-3.0.22-stable-src.tar.gz
cd privoxy-3.0.22-stable

autoheader
autoconf

CC=$CC \
CXX=$CXX \
CPPFLAGS=$CPPFLAGS \
LDFLAGS=$LDFLAGS \
$CONFIGURE

$MAKE LIBS="-static -lpcre -lz"
make install DESTDIR=$BASE/privoxy
