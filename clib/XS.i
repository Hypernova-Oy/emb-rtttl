%module "RTTTL::XS"
%{
/* Put header files here or function declarations like below */
extern void play_tone( int pin, int tone, int duration );
extern void play_rtttl( int pin, char *notes );
extern void init(int pin, int _verbose);
%}

extern void play_tone( int pin, int tone, int duration );
extern void play_rtttl( int pin, char *notes);
extern void init(int pin, int _verbose);
