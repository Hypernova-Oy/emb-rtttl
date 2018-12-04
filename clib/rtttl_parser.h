#ifndef RTTTL_PARSER_HEADER_FILE
#define RTTTL_PARSER_HEADER_FILE

struct Tone {
  uint32_t frequency;
  uint16_t duration;
};

struct Song {
  char name[11];
  int tonesCount;
  struct Tone tones[1024];
};

struct Song parse_rtttl(char *rtttl_song);

#endif
