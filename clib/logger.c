#include "logger.h"
#include <stdio.h>
#include <stdlib.h>

short logLevel;

void loginit(short level) {
  logLevel = level;
}

void logp(const short level, char* message) {
  if (level > logLevel) {
    return;
  }

  char *tag;
  switch (level) {
    case FATAL: tag = "FATAL"; break;
    case ERROR: tag = "ERROR"; break;
    case WARN:  tag = "WARN "; break;
    case INFO:  tag = "INFO "; break;
    case DEBUG: tag = "DEBUG"; break;
    case TRACE: tag = "TRACE"; break;
  }

  printf("[%s]: %s\n", tag, message);
}


//
// If compiled as a stand-alone program
// Runs a simple test suite
//
#ifndef NOMAIN
int main(int argc,char const *argv[]) {
  printf("loginit TRACE\n");
  loginit(TRACE);

  logp(TRACE, "trace message");
  logp(DEBUG, "debug message");
  logp(INFO , "info  message");
  logp(WARN , "warn  message");
  logp(ERROR, "error message");
  logp(FATAL, "fatal message");

  printf("loginit ERROR\n");
  loginit(ERROR);

  logp(TRACE, "trace message");
  logp(DEBUG, "debug message");
  logp(INFO , "info  message");
  logp(WARN , "warn  message");
  logp(ERROR, "error message");
  logp(FATAL, "fatal message");

  return 0;
}
#endif
