/* Standard libaries */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>

#include "drv_Io1035Utils.hpp"
#include "drv_Io1035.hpp"

#define DATA0_LO    0x00000000  /* Little endian */
#define DATA0_HI    0x01000001
#define nCONFIG_LO  0x00000000  /* Little endian */
#define nCONFIG_HI  0x00000000
#define DCLK_LO     0x00000000  /* Little endian */
#define DCLK_HI     0x00010100

#define BUFFER_SIZE   1024  /* MUST BE A MULTIPLE OF 16 */
#define BUFFER_SIZE32 (BUFFER_SIZE*2*4*8)


/*****************************************************************************
*                                                                            *
*  Routine       FPGA Parity bit send                                        *
*                                                                            *
*  Arguments     ptr  ptr to data                                            *
*                                                                            *
*  Returns       -                                                           *
*                                                                            *
*  Description   Send the SW to the FPGA, via PLX parity bits                *
*                See Altera Application Note 116 for details                 *
*                                                                            *
*****************************************************************************/
static void formatBuffer ( char* ptr, uint32_t* ptr32, uint16_t nrOfBytes )
{
  uint16_t idx;
  uint8_t  sh;

  for ( idx = 0; idx < nrOfBytes; idx++ )
  {
    for ( sh=1; sh; sh <<= 1 )
    {
      if (ptr[idx] & sh)
      {
        *ptr32     = DCLK_LO + DATA0_HI + nCONFIG_HI;
        *(ptr32+1) = DCLK_HI + DATA0_HI + nCONFIG_HI;
      }
      else
      {
        *ptr32     = DCLK_LO + DATA0_LO + nCONFIG_HI;
        *(ptr32+1) = DCLK_HI + DATA0_LO + nCONFIG_HI;
      }
      ptr32 += 2;
    }
  }
} // static void formatBuffer ( char* ptr, uint32_t* ptr32, uint16_t nrOfBytes )


/*****************************************************************************
*                                                                            *
*  Routine       FPGA Load                                                   *
*                                                                            *
*  Arguments     filename     FPGA code in .rbf format                       *
*                displayInfo  TRUE  display, FALSE No display                *
*                                                                            *
*  Returns       TRUE if succeeded, FALSE otherwise                          *
*                                                                            *
*  Description   Load the FPGA                                               *
*                See Altara Application Note 116 for details                 *
*                                                                            *
*****************************************************************************/
bool io1035FpgaLoad ( bool displayInfo, char* fileName )
{
  float   time;
  char*   buffer;
  char*   buffer32;
  int     nrOfBytes;
  bool    retval;
  int     fd;
  int     fileSize;
  int     st;

  buffer = (char*) malloc (BUFFER_SIZE);
  buffer32 = (char*) malloc (BUFFER_SIZE32);
  fileSize = 0;
  retval = false;

  if ((fileName[0] != '*') && (fileName[0] != '+'))
    fd = open (fileName, O_RDONLY, 0);    
  else
    fd = open (&fileName[1], O_RDONLY, 0);

  if (fd != -1)
  {
    retval = true;
    fileSize = 0;
    nrOfBytes = BUFFER_SIZE;

    while (nrOfBytes == BUFFER_SIZE)
    {
      nrOfBytes = read (fd, buffer, BUFFER_SIZE);
      if (nrOfBytes == -1)
      {
        retval = false;
      }
      else
      {
        formatBuffer (buffer, (uint32_t*) buffer32, nrOfBytes);
        if      (fileName[0] == '*') { st = load1035FpgaNoDma(buffer32, (nrOfBytes*2*4*8)); }
//        else if (fileName[0] == '+') { st = loadFpgaSerEE    (buffer  , (nrOfBytes      )); }
        else                         { st = load1035FpgaNoDma(buffer32, (nrOfBytes*2*4*8)); }

        if (st == -1)
        {
          nrOfBytes = 0;  /* Stop */
          retval = false;
        }
        if (displayInfo)
        {
          fileSize += nrOfBytes;
          if ((fileSize % (100*BUFFER_SIZE)) == 0)
            printf("-");
        }
      }
    } /* while BUFFER_SIZE */

    if (retval)
    {
      memset(buffer,0xFF,25);     // 200 extra clocks to SBK 
      formatBuffer (buffer, (uint32_t*) buffer32, 25);
      if (fileName[0] != '*')
        load1035FpgaNoDma(buffer32, (25*8*2*4));
      else
        load1035FpgaNoDma(buffer32, (25*8*2*4));
    }

    if (displayInfo)
      printf("\n");

    if (close(fd) == -1)
      retval = false;

  } /* if open == ERROR */
  else
    retval = false;

  if (displayInfo)
  {
    printf("FPGA file   :\n\"%s\"\n",fileName);
    printf("Loaded bytes: %d\n",fileSize);
  }
  free (buffer);
  free (buffer32);

  return (retval);
} /* FpgaLoad */

