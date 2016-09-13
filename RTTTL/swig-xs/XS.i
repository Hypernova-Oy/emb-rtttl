%module "RTTTL::XS"
%{
/* Put header files here or function declarations like below */
extern void play_rtttl( int pin, char *notes );
%}

extern void play_rtttl( int pin, char *notes);
