#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <wiringPi.h>
#include <softTone.h>

#define OCTAVE_OFFSET 0

int notes[] = { 0,
262,277,294,311,330,349,370,392,415,440,466,494,
523,554,587,622,659,698,740,784,831,880,932,988,
1047,1109,1175,1245,1319,1397,1480,1568,1661,1760,1865,1976,
2093,2217,2349,2489,2637,2794,2960,3136,3322,3520,3729,3951
};

//Have a defautl song for testing purposes
char *song = "nyancat:d=4,o=5,b=90:16d#6,16e6,8f#6,8b6,16d#6,16e6,16f#6,16b6,16c#7,16d#7,16c#7,16a#6,8b6,8f#6,16d#6,16e6,8f#6,8b6,16c#7,16a#6,16b6,16c#7,16e7,16d#7,16e7,16c#7,8f#6,8g#6,16d#6,16d#6,16p,16b,16d6,16c#6,16b,16p,8b,8c#6,8d6,16d6,16c#6,16b,16c#6,16d#6,16f#6,16g#6,16d#6,16f#6,16c#6,16d#6,16b,16c#6,16b,8d#6,8f#6,16g#6,16d#6,16f#6,16c#6,16d#6,16b,16d6,16d#6,16d6,16c#6,16b,16c#6,8d6,16b,16c#6,16d#6,16f#6,16c#6,16d#6,16c#6,16b,8c#6,8b,8c#6,8f#6,8g#6,16d#6,16d#6,16p,16b,16d6,16c#6,16b,16p,8b,8c#6,8d6,16d6,16c#6,16b,16c#6,16d#6,16f#6,16g#6,16d#6,16f#6,16c#6,16d#6,16b,16c#6,16b,8d#6,8f#6,16g#6,16d#6,16f#6,16c#6,16d#6,16b,16d6,16d#6,16d6,16c#6,16b,16c#6,8d6,16b,16c#6,16d#6,16f#6,16c#6,16d#6,16c#6,16b,8c#6,8b,8c#6,8b,16f#,16g#,8b,16f#,16g#,16b,16c#6,16d#6,16b,16e6,16d#6,16e6,16f#6,8b,8b,16f#,16g#,16b,16f#,16e6,16d#6,16c#6,16b,16f#,16d#,16e,16f#,8b,16f#,16g#,8b,16f#,16g#,16b,16b,16c#6,16d#6,16b,16f#,16g#,16f#,8b,16b,16a#,16b,16f#,16g#,16b,16e6,16d#6,16e6,16f#6,8b,8a#,8b,16f#,16g#,8b,16f#,16g#,16b,16c#6,16d#6,16b,16e6,16d#6,16e6,16f#6,8b,8b,16f#,16g#,16b,16f#,16e6,16d#6,16c#6,16b,16f#,16d#,16e,16f#,8b,16f#,16g#,8b,16f#,16g#,16b,16b,16c#6,16d#6,16b,16f#,16g#,16f#,8b,16b,16a#,16b,16f#,16g#,16b,16e6,16d#6,16e6,16f#6,8b,8c#6";

int defaultTonePin = 1; //Default pin
int verbose = 0;

#define isdigit(n) (n >= '0' && n <= '9')

void init(int pin, int _verbose)
{
    verbose = _verbose;
    wiringPiSetup();
    softToneCreate(pin);
}

void play_tone(int pin, int tone, int duration)
{
    if (verbose == 1)
    {
        printf("play_tone(%i, %i, %i)\n",pin, tone, duration);
    }
    softToneWrite(pin, tone);
    delay(duration);
    softToneWrite(pin, 0);
}

void play_rtttl(int pin, char *p)
{

        // Absolutely no error checking in here

        //printf("%s","8000 ");

        uint8_t default_dur = 4;
        uint8_t default_oct = 6;
        int bpm = 63;
        int num;
        uint32_t wholenote;
        int duration;
        uint8_t note;
        uint8_t scale;

        // format: d=N,o=N,b=NNN:
        // find the start (skip name,etc)

        while(*p != ':') p++;    // ignore name
        p++;                     // skip ':'

        // get default duration
        if(*p == 'd')
        {
                p++; p++;              // skip "d="
                num = 0;
                while(isdigit(*p))
                {
                        num = (num * 10) + (*p++ - '0');
                }
                if(num > 0) default_dur = num;
                p++;                   // skip comma
        }

        //printf("ddur: "); printfln(default_dur,10);

        // get default octave
        if(*p == 'o')
        {
                p++; p++;              // skip "o="
                num = *p++ - '0';
                if(num >= 3 && num <=7) default_oct = num;
                p++;                   // skip comma
        }

        //printf("doct: "); printfln(default_oct,10);

        // get BPM
        if(*p == 'b')
        {
                p++; p++;              // skip "b="
                num = 0;
                while(isdigit(*p))
                {
                        num = (num * 10) + (*p++ - '0');
                }
                bpm = num;
                p++;                   // skip colon
        }

        //printf("bpm: "); printfln(bpm,10);

        // BPM usually expresses the number of quarter notes per minute
        wholenote = (60 * 1000L / bpm) * 4;  // this is the time for whole note (in milliseconds)

        //printf("wn: "); printfln(wholenote,10);


        // now begin note loop
        while(*p)
        {
                // first,get note duration,if available
                num = 0;
                while(isdigit(*p))
                {
                        num = (num * 10) + (*p++ - '0');
                }

                if(num) duration = wholenote / num;
                else duration = wholenote / default_dur;  // we will need to check if we are a dotted note after

                // now get the note
                note = 0;

                switch(*p)
                {
                        case 'c':
                                note = 1;
                                break;
                        case 'd':
                                note = 3;
                                break;
                        case 'e':
                                note = 5;
                                break;
                        case 'f':
                                note = 6;
                                break;
                        case 'g':
                                note = 8;
                                break;
                        case 'a':
                                note = 10;
                                break;
                        case 'b':
                                note = 12;
                                break;
                        case 'p':
                        default:
                                note = 0;
                }
                p++;

                // now,get optional '#' sharp
                if(*p == '#')
                {
                        note++;
                        p++;
                }

                // now,get optional '.' dotted note
                if(*p == '.')
                {
                        duration += duration/2;
                        p++;
                }

                // now,get scale
                if(isdigit(*p))
                {
                        scale = *p - '0';
                        p++;
                }
                else
                {
                        scale = default_oct;
                }

                scale += OCTAVE_OFFSET;

                if(*p == ',')
                        p++;       // skip comma for next note (or we may be at the end)

                // now play the note

                if(note)
                {
                        play_tone( pin, notes[(scale - 4) * 12 + note]  ,  duration );
                }
                else
                {
                        play_tone( pin, 0 , duration );
                }
        }
}

int main(int argc,char const *argv[])
{
        init(defaultTonePin, verbose);
        play_rtttl(defaultTonePin, song);
        return 0;
}

