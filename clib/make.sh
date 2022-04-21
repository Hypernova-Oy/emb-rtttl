echo "Compiling all libraries"
gcc -DNOMAIN -c logger.c rtttl_parser.c

echo "Building the logger as a standalone"
gcc logger.c -o logger
echo "Test it with:"
echo "./logger"
echo ""
echo "Building the rtttl_parser as a standalone"
gcc rtttl_parser.c logger.o -o rtttl_parser
echo "Test it with:"
echo "./rtttl_parser"
echo ""
echo "Building the rtttl_player as a standalone"
gcc XS.c logger.o rtttl_parser.o -o rtttl_player -lwiringPi -lpthread
echo "Test it with:"
echo "./rtttl_player"
echo ""
