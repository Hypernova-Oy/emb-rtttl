echo "Compiling the logger as a standalone"
gcc logger.c -o logger
echo "Test it with:"
echo "./logger"
echo ""
echo "Compiling the rtttl_parser as a standalone"
gcc -D NOMAIN -c logger.c
gcc -c rtttl_parser.c
gcc logger.o rtttl_parser.o -o rtttl_parser
echo "Test it with:"
echo "./rtttl_parser"
echo ""
echo "Compiling the rtttl_player as a standalone"
gcc -D NOMAIN -c logger.c
gcc -D NOMAIN -c rtttl_parser.c
gcc -c XS.c -lwiringPi -lpthread
gcc logger.o rtttl_parser.o XS.o -o rtttl_player -lwiringPi -lpthread
echo "Test it with:"
echo "./rtttl_player"
echo ""
