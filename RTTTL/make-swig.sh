#!/bin/bash

gccWiringPiDeps="-lwiringPi -lpthread"

##BUILD Perl XS madness using handy dandy swig <3
cd swig-xs
swig -perl5 RTTTL.i
gcc -c `perl -MConfig -e 'print join(" ", @Config{qw(ccflags optimize cccdlflags)}, \
        "-I$Config{archlib}/CORE")'` RTTTL.c RTTTL_wrap.c $gccWiringPiDeps=
gcc `perl -MConfig -e 'print $Config{lddlflags}'` RTTTL.o RTTTL_wrap.o -o RTTTL.so $gccWiringPiDeps=
cp RTTTL.pm ../
cp RTTTL.so ../
cd ..

