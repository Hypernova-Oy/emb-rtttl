%module "RTTTL::XS"
%{
/* Put header files here or function declarations like below */
extern void play_tone(int tone, int duration);
extern void play_rtttl(char *notes);
extern void init(int pin, int _verbose);
%}

extern void play_tone(int tone, int duration);
extern void play_rtttl(char *notes);
extern void init(int pin, int _verbose);
