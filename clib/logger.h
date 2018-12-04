#ifndef LOGGER_HEADER_FILE
#define LOGGER_HEADER_FILE

#define FATAL 0
#define ERROR 1
#define WARN  2
#define INFO  3
#define DEBUG 4
#define TRACE 5

void loginit(short level);

void logp(short level, char* message);

#endif /* LOGGER_HEADER_FILE */
