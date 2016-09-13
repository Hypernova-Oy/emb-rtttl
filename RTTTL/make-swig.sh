#!/bin/bash

gccWiringPiDeps="-lwiringPi -lpthread"

##BUILD Perl XS madness using handy dandy swig <3
cd swig-xs
swig -perl5 XS.i
gcc -c `perl -MConfig -e 'print join(" ", @Config{qw(ccflags optimize cccdlflags)}, \
        "-I$Config{archlib}/CORE")'` XS.c XS_wrap.c $gccWiringPiDeps
gcc `perl -MConfig -e 'print $Config{lddlflags}'` XS.o XS_wrap.o -o XS.so $gccWiringPiDeps
mkdir -p ../RTTTL
cp XS.pm ../RTTTL/
cp XS.so ../RTTTL/
cd ..

