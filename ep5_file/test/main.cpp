#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>

#include "drv_Io1035Utils.hpp"
#include "drv_Io1035.hpp"

extern volatile uint32_t* io1035RegisterPtr;

const uint32_t MAP_SIZE = 1024*1024;

int main(int argc, char *argv[])
{
    if (argc < 3)
    {
        fprintf(stderr, "Usage: app <sysfs device> <file>\n");
        exit(-1);
    }

    int fd = open(argv[1], O_RDWR | O_SYNC);
    if (fd == -1)
    {
        fprintf(stderr, "File not found: %s\n", argv[1]);
        exit(-2);
    }

    io1035RegisterPtr = (uint32_t*) mmap(0, MAP_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);

    io1035FpgaLoad (true, argv[2]);
}

