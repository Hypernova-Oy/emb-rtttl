cBuildDir=./cbuild
cLib=./clib
pLib=./lib
pPackage=RTTTL
systemCDir=/usr/lib
systemConfigBaseDir=/etc
programName=emb-rtttl


gccWiringPiDeps=-lwiringPi -lpthread


#Macro to check the exit code of a make expression and possibly not fail on warnings
RC      := test $$? -lt 100 


build: compile

install: build link configure

compile:
	##BUILD Perl XS madness using handy dandy swig <3
	mkdir -p $(cBuildDir)
	cp -r $(cLib)/* $(cBuildDir)/
	cd $(cBuildDir); \
	\
	swig -perl5 XS.i; \
	\
	gcc -c `perl -MConfig -e 'print join(" ", @Config{qw(ccflags optimize cccdlflags)}, \
	       	"-I$$Config{archlib}/CORE")'` XS.c XS_wrap.c $(gccWiringPiDeps); \
	\
	gcc -shared `perl -MConfig -e 'print $$Config{lddlflags}'` XS.o XS_wrap.o -o XS.so $(gccWiringPiDeps);

	cp $(cBuildDir)/XS.pm $(pLib)/$(pPackage)/
	cp $(cBuildDir)/XS.so $(pLib)/$(pPackage)/

	rm -r $(cBuildDir)

test: compile
	prove -Ilib -Ilib/$(pPackage) t/*.t

configure:
	mkdir -p $(systemConfigBaseDir)/$(programName)
	cp config/config $(systemConfigBaseDir)/$(programName)/config

unconfigure:
	rm -r $(systemConfigBaseDir)/$(programName) || $(RC)

link: compile
	cp $(pLib)/$(pPackage)/XS.so $(systemCDir)/XS.so

unlink:
	rm $(systemCDir)/XS.so || $(RC)

clean:
	rm $(pLib)/$(pPackage)/XS.so || $(RC)

uninstall: unlink unconfigure clean

