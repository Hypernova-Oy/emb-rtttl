cBuildDir=./cbuild
cLib=./clib
pLib=./lib
pPackage=RTTTL
systemCDir=/usr/lib
programName=emb-rtttl
confDir=etc/$(programName)
runDir=var/run/$(programName)
systemdServiceDir=etc/systemd/system
systemPath=/usr/local/bin
cronDir=etc/cron.d


gccWiringPiDeps=-lwiringPi -lpthread


#Macro to check the exit code of a make expression and possibly not fail on warnings
RC      := test $$? -lt 100


build: compile

restart:

install: build link configure scriptsLink
	./Build installdeps
	./Build install

compile:
	##BUILD Perl XS madness using handy dandy swig <3
	mkdir -p $(cBuildDir)
	cp -r $(cLib)/* $(cBuildDir)/
	cd $(cBuildDir); \
	\
	swig -perl5 XS.i; \
	\
        gcc -c -D NOMAIN logger.c rtttl_parser.c; \
	gcc -c `perl -MConfig -e 'print join(" ", @Config{qw(ccflags optimize cccdlflags)}, \
		"-I$$Config{archlib}/CORE")'` \
		XS.c XS_wrap.c $(gccWiringPiDeps); \
	\
	gcc -shared `perl -MConfig -e 'print $$Config{lddlflags}'` \
		logger.o rtttl_parser.o XS.o XS_wrap.o -o XS.so $(gccWiringPiDeps); \


	cp $(cBuildDir)/XS.pm $(pLib)/$(pPackage)/
	cp $(cBuildDir)/XS.so $(pLib)/$(pPackage)/

	rm -r $(cBuildDir)

	#Build Perl modules
	perl Build.PL
	./Build

test:
	prove -Ilib -Ilib/$(pPackage) t/*.t

configure:
	mkdir -p /$(confDir)
	(test ! -f /$(confDir)/config && cp $(confDir)/config /$(confDir)/config) || $(RC)

	mkdir -p /var/local/rtttl
	cp rtttl/* /var/local/rtttl/

	mkdir -p /$(runDir)

	(test ! -f /$(cronDir)/$(programName) && cp $(cronDir)/$(programName) /$(cronDir)/$(programName)) || $(RC)

	cp $(systemdServiceDir)/$(programName).service /$(systemdServiceDir)/
	systemctl enable emb-rtttl
	systemctl start emb-rtttl

unconfigure:
	rm -r /$(confDir) || $(RC)
	rm -r /var/local/rtttl || $(RC)
	rm -r /$(runDir) || $(RC)
	rm /$(cronDir)/$(programName) || $(RC)
	rm /$(systemdServiceDir)/$(programName).service || $(RC)
	systemctl disable emb-rtttl
	systemctl stop emb-rtttl

link: compile
	cp $(pLib)/$(pPackage)/XS.so $(systemCDir)/XS.so

unlink:
	rm $(systemCDir)/XS.so || $(RC)

scriptsLink:
	cp scripts/rtttl-player $(systemPath)/

scriptsUnlink:
	rm $(systemPath)/rtttl-player

clean:
	rm $(pLib)/$(pPackage)/XS.so || $(RC)
	./Build realclean

uninstall: unlink unconfigure scriptsUnlink clean

