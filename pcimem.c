/*
 * pcimem.c: Simple program to read/write from/to a pci device from userspace.
 *
 *  Copyright (C) 2010, Bill Farrow (bfarrow@beyondelectronics.us)
 *
 *  Based on the devmem2.c code
 *  Copyright (C) 2000, Jan-Derk Bakker (J.D.Bakker@its.tudelft.nl)
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>
#include <signal.h>
#include <fcntl.h>
#include <ctype.h>
#include <termios.h>
#include <sys/types.h>
#include <sys/mman.h>
#include <linux/pci.h>


#define PRINT_ERROR \
    do { \
        fprintf(stderr, "Error at line %d, file %s (%d) [%s]\n", \
        __LINE__, __FILE__, errno, strerror(errno)); exit(1); \
    } while(0)

#define MAP_SIZE 4096UL
#define MAP_MASK (MAP_SIZE - 1)

int main(int argc, char **argv) {
    int fd; 
    void *map_base, *virt_addr;
    uint32_t read_result, writeval;
    char *filename;
    off_t target;
    int access_type = 'w';

    if(argc < 3) {
        // pcimem /sys/bus/pci/devices/0001\:00\:07.0/resource0 0x100 w 0x00
        // argv[0]  [1]                                         [2]   [3] [4]
        fprintf(stderr, "\nUsage:\t%s { sys file } { offset } [ type [ data ] ]\n"
                "\tsys file: sysfs file for the pci resource to act on\n"
                "\toffset  : offset into pci memory region to act upon\n"
                "\ttype    : access operation type : [b]yte, [h]alfword, [w]ord\n"
                "\tdata    : data to be written\n\n",
                argv[0]);
        exit(1);
    }   
    filename = argv[1];
    target = strtoul(argv[2], 0, 0); 

    if(argc > 3)
        access_type = tolower(argv[3][0]);

    if((fd = open(filename, O_RDWR | O_SYNC)) == -1){
        PRINT_ERROR;
    }
    printf("%s opened.\n", filename);
    printf("Target offset is 0x%x, page size is %ld map mask is 0x%lX\n", (int) target, sysconf(_SC_PAGE_SIZE), MAP_MASK);
    fflush(stdout);

    /* Map one page */
#if 0
    //map_base = mmap(0, MAP_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, fd, (off_t) (target & ~MAP_MASK));
    //map_base = mmap(0, MAP_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, fd, target & ~MAP_MASK);
#endif
    printf("mmap(%d, %ld, 0x%x, 0x%x, %d, 0x%x)\n", 0, MAP_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, fd, (int) (target & ~MAP_MASK));
    map_base = mmap(0, MAP_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, fd, (target & ~MAP_MASK));
    if(map_base == (void *) -1){
       printf("PCI Memory mapped ERROR.\n");
        PRINT_ERROR;
        close(fd);
        return 1;
    }

    printf("mmap(%d, %ld, 0x%x, 0x%x, %d, 0x%x)\n", 0, MAP_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, fd, (int) (target & ~MAP_MASK));
    printf("PCI Memory mapped %ld byte region to map_base 0x%08lx.\n", MAP_SIZE, (unsigned long) map_base);
    fflush(stdout);

    virt_addr = map_base + (target & MAP_MASK);
    printf("PCI Memory mapped access 0x %08lX.\n", (uint64_t ) virt_addr);
   switch(access_type) {
        case 'b':
                read_result = *((volatile uint8_t *) virt_addr);
                break;  
        case 'h':
                read_result = *((volatile uint16_t *) virt_addr);
                break;  
        case 'w':
                read_result = *((volatile uint32_t *) virt_addr);
                        printf("READ Value at offset 0x%X (%p): 0x%X\n", (int) target, virt_addr, read_result);
                break;
        default:
                fprintf(stderr, "Illegal data type '%c'.\n", access_type);
                exit(2);
    }
    fflush(stdout);

    if(argc > 4) {
        writeval = strtoul(argv[4], 0, 0);
        switch(access_type) {
                case 'b':
                        *((volatile uint8_t *) virt_addr) = writeval;
                        read_result = *((volatile uint8_t *) virt_addr);
                        break;
                case 'h':
                        *((volatile uint16_t *) virt_addr) = writeval;
                        read_result = *((volatile uint16_t *) virt_addr);
                        break;
                case 'w':
                        *((volatile uint32_t *) virt_addr) = writeval;
                        read_result = *((volatile uint32_t *) virt_addr);
                        break;
        }
        printf("Written 0x%X; readback 0x%X\n", writeval, read_result);
        fflush(stdout);
    }

    if(munmap(map_base, MAP_SIZE) == -1) { PRINT_ERROR;}
    close(fd);
    return 0;
}

