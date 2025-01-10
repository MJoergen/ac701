/*****************************************************************************
*                                                                            *
* Project              Orca                                                  *
* Module               Driver, IO1035                                        *
*                                                                            *
* Directory            /sources/IO1035                                       *
* Filename             drv_IO1035.cpp                                        *
*                                                                            *
* P:\IP\Hardware\PCB10xx\PCB1035\PCB1035-0\FPGA\Doc                          *
*                                                                            *
* Date                 2022/09                                               *
*                                                                            *
* Description          IO1035 FPGA driver, in large part based off IO1020    *
*                      FPGA functionality, see corresponding 1020 files.     *
*                                                                            *
*                                                                            *
*                                                                            *
*****************************************************************************/


/* Standard libraries */
#include <stdint.h>
#include <string.h>

#include "drv_Io1035.hpp"
#include "drv_Io1035Utils.hpp"

/* Definitions */
#define IRQ_IO1035_UART0        BIT0
#define IRQ_IO1035_UART1        BIT1
#define IRQ_IO1035_UART2        BIT2
#define IRQ_IO1035_UART3        BIT3
#define IRQ_IO1035_UART4        BIT4
#define IRQ_IO1035_UART5        BIT5
#define IRQ_IO1035_UART6        BIT6
#define IRQ_IO1035_UART7        BIT7
//#define IRQ_IO1035_UART8        BIT8
//#define IRQ_IO1035_UART9        BIT9
//#define IRQ_IO1035_UART10       BIT10
//#define IRQ_IO1035_UART11       BIT11
#define IRQ_IO1035_CAN_IRW      BIT12
#define IRQ_IO1035_CAN_RX0      BIT13
#define IRQ_IO1035_CAN_RX1      BIT14
#define IRQ_IO1035_DISPLAY_RST  BIT15
#define IRQ_IO1035_I2C          BIT16
#define IRQ_IO1035_DISPLAY_KEY  BIT17
#define IRQ_IO1035_SERVO        BIT18
#define IRQ_IO1035_TRIGGER      BIT19
#define IRQ_IO1035_SAFETY       BIT20
#define IRQ_IO1035_IRIG_1_PPS   BIT21
#define IRQ_IO1035_IRIG_NO_LOCK BIT22
#define IRQ_IO1035_SSI0         BIT23
#define IRQ_IO1035_SSI1         BIT24
#define IRQ_IO1035_SSI2         BIT25
#define IRQ_IO1035_SSI3         BIT26
#define IRQ_IO1035_SPI_0        BIT27
#define IRQ_IO1035_SPI_1        BIT28
#define IRQ_IO1035_SPI_2        BIT29
#define IRQ_IO1035_SPI_3        BIT30
#define IRQ_IO1035_SPI_4        BIT31


#define DISPLAYKEY_UP           0 // BIT0
#define DISPLAYKEY_DOWN         1 // BIT1
#define DISPLAYKEY_ENTER        2 // BIT2
#define DISPLAYKEY_QUIT         3 // BIT3
#define DISPLAYKEY_MODE         4 // BIT4
#define DISPLAYKEY_RIGHT        4 // BIT4
#define DISPLAYKEY_MEASURE      5 // BIT5
#define DISPLAYKEY_LEFT         5 // BIT5
#define DISPLAYKEY_ONOFF        6 // BIT5
#define DISPLAYKEY_NONE         7 // BIT5
#define DISPLAYKEY_DISCONNECTED 8 // 80,81
#define NR_OF_DISPLAY_KEYS      9

#define BAR2_MEMORY_SIZE        (0x200000) // Base Address Register 2 size

#define ADDROFFSET_UART         0x1000
#define ADDROFFSET_SPI0         0x2000
#define ADDROFFSET_SPI1         0x3000
#define ADDROFFSET_SPI2         0x4000
#define ADDROFFSET_SPI3         0x5000
//#define ADDROFFSET_I2C          0x7000 // Old 1030 I2C controller
#define ADDROFFSET_I2C          0x10200   // New 1035 I2C Controller
#define ADDROFFSET_ENDAT0       0x8000
#define ADDROFFSET_ENDAT1       0x9000
#define ADDROFFSET_ENDAT2       0xA000
#define ADDROFFSET_ENDAT3       0xB000
#define ADDROFFSET_IRIG         0xC000
#define ADDROFFSET_DISPLAY      0xD000
#define ADDROFFSET_BISS0        0xE000
#define ADDROFFSET_BISS1        0xF000


#define DMA_BUFFER_SIZE         (1024*8*4*2)
#define LOAD_FPGA_ADDRESS       0x00000004 // Version Register

#define MAX_NESTED_INTERRUPTS   100

#define t_CFG                   8  /* microseconds */
#define t_CF2CK                 40 /* microseconds */

#define IO1035_NO_OF_TSENSE           7      // Kontron 1, 2, DC-DC, 3x TempSense, LSM6DSM
#define IO1035_NUMBER_OF_FANS         6      // RCU fans
#define IO1035_FAN_SPEED_THRESHOLD    25     // Percent error permissible
#define IO1035_TEMP_AVERAGE_LENGTH    5      // Samples
#define IO1035_SLOW_FAN_TEMP          30.0f  // Celsius (when reached, minimum fan speed)
#define IO1035_FULL_FAN_TEMP          75.0f  // Celsius (when reached, maximum fan speed)
#define IO1035_MINIMUM_FAN_SPEED      15.0f  // Percent
#define IO1035_MAXIMUM_FAN_SPEED      100.0f // Percent

#define IO1035_FAN_SPEED_TEMP_SLOPE ( ( IO1035_MAXIMUM_FAN_SPEED -    \
                                        IO1035_MINIMUM_FAN_SPEED ) /  \
                                      ( IO1035_FULL_FAN_TEMP -        \
                                        IO1035_SLOW_FAN_TEMP ) ) // Percent fan speed per degree celsius

#define IO1035_FAN_SPEED_TEMP_ZERO_INTERCEPT ( ( IO1035_MINIMUM_FAN_SPEED    - \
                                                 IO1035_FAN_SPEED_TEMP_SLOPE * \
                                                 IO1035_SLOW_FAN_TEMP ) ) // Percent fan speed at zero degree celsius (theoretical)

#define IO1035_100M_FREQ  100*1000*1000

#define IO1035_PLOT_WIDTH  46
#define IO1035_PLOT_HEIGHT 13

static int clockVals[IO1035_PLOT_WIDTH] = { 0 };

static int dac_value = 0;


/* PI controller values and errors */
#define KP_COARSE 1
#define KI_COARSE 16

#define KP_FINE   1
#define KI_FINE   2

int Kp = KP_COARSE;
int Ki = KI_COARSE;

int errorP    = 0;  /* Proportional error */
int errorI    = 0;  /* Integral error */
int errorAcc  = 0;  /* Accumulated error (drive to zero over time) */
int dacBias   = 0;

/* Enumerations */
enum countInterrupts {
  INT_IO1035 = 0,
  INT_IO1035_FPGA,
  INT_IO1035_Dma0,
  INT_IO1035_Dma1,
  INT_IO1035_UART0,
  INT_IO1035_UART1,
  INT_IO1035_UART2,
  INT_IO1035_UART3,
  INT_IO1035_UART4,
  INT_IO1035_UART5,
  INT_IO1035_UART6,
  INT_IO1035_UART7,
  INT_IO1035_CAN_IRW,
  INT_IO1035_CAN_RX0,
  INT_IO1035_CAN_RX1,
  INT_IO1035_DISPLAY_RST,
  INT_IO1035_I2C,
  INT_IO1035_DISPLAY_KEY,
  INT_IO1035_SERVO,
  INT_IO1035_TRIGGER,
  INT_IO1035_SAFETY,
  INT_IO1035_IRIG_1_PPS,
  INT_IO1035_IRIG_NO_LOCK,
  INT_IO1035_SSI0,
  INT_IO1035_SSI1,
  INT_IO1035_SSI2,
  INT_IO1035_SSI3,
  INT_IO1035_SPI_0,
  INT_IO1035_SPI_1,
  INT_IO1035_SPI_2,
  INT_IO1035_SPI_3,
  INT_IO1035_SPI_4,
  INT_IO1035_Unknown,
  INT_IO1035_Unknown_FPGA,
  NR_OF_COUNT_INTERRUPTS
};



/* Static variables */
volatile uint32_t*                               io1035RegisterPtr     = NULL;   // FPGA base addr

static bool   s_io1035Found    = false;
static bool   s_fpgaRunning    = false;
static char   s_dmaBuffer1[DMA_BUFFER_SIZE];

#if ( _WRS_VXWORKS_MAJOR >= 7 )
  // Physical (DMA-accessible) address of s_dmaBuffer1
  static PHYS_ADDR s_dmaBuffer1Physical = 0;
#endif

static uint32_t s_nrOfInts[NR_OF_COUNT_INTERRUPTS];
static uint32_t s_nrOfIntsPrSec[NR_OF_COUNT_INTERRUPTS];
static uint32_t s_nrOfIntsPrSecDisp[NR_OF_COUNT_INTERRUPTS];
static uint8_t  s_intLine;
static uint32_t s_maxIntCount;
static bool     s_allowIo1035Int = true;

static uint32_t   s_last100MHzCount = 0xFFFFFFFF;
static uint32_t   s_last100MHzValue = 0;
static int32_t    s_intError100MHz  = 0;
static int8_t     s_stable100MHz    = -10;

static long unsigned int loadCnt = 0;
static long unsigned int loadSum = 0;
static long unsigned int display = 0;

/* Temperature regulation variables */
static float   s_TempMeas[IO1035_NO_OF_TSENSE][IO1035_TEMP_AVERAGE_LENGTH] = { 0 };
static float   s_TempMeasSum[IO1035_NO_OF_TSENSE] = { 0 }; // Cumulative sum
static float   s_TempMeasAvg[IO1035_NO_OF_TSENSE] = { 0 };
static uint8_t s_WindowIdx = 0;
static bool    s_FanControlState = true;

/* Dynamic azimuth power zone variables */
static uint8_t s_EncoderResolution = 0;
static double  s_EncoderOffset = 0.0;
static double  s_TxLimitArray[IO1035_TRANSMIT_ZONE_COUNT][2]    = { 0.0 };
static double  s_BlockLimitArray[IO1035_BLOCKING_ZONE_COUNT][2] = { 0.0 };
static double  s_Heading = 0.0;

/* Forward function declarations */
static uint32_t io1035DrvConvertDouble2Bin ( double angle );




int load1035FpgaNoDma ( char* buf, int nbytes )
{
  int i, idx;
  int nlongs;
  uint32_t* ptr;
  uint32_t swapped;

  printf("*");
  i = nbytes;

  do
  {
    if (i > DMA_BUFFER_SIZE)
    {
      printf("#######");
      memcpy (s_dmaBuffer1, buf, DMA_BUFFER_SIZE);
      buf = buf + DMA_BUFFER_SIZE;
      nlongs = ((DMA_BUFFER_SIZE-1) / 4) + 1;
      i -=  DMA_BUFFER_SIZE;
    }
    else
    {
      memcpy (s_dmaBuffer1, buf, i);
      nlongs = ((i-1) / 4) + 1;
      i = 0;
    }

    ptr = (uint32_t*)s_dmaBuffer1;    
    idx = 0;
    while (idx < nlongs)
    {
      swapped = ptr[idx]; 
      io1035RegisterPtr[IO1035_version]     = swapped;  
      idx++;
      loadCnt++; // for (count = 0; count < 100; count++);
      loadSum+=((swapped>>24) & 0xFF);
      loadSum+=((swapped>>16) & 0xFF);
      loadSum+=((swapped>> 8) & 0xFF);
      loadSum+=((swapped    ) & 0xFF);
    }
  } while (i > 0);

  if (nbytes == (25*8*2*4))
  {
    printf("\n*** Done *** (%ld) %08lX\n", loadCnt, loadSum);
    loadCnt = 0; 
    loadSum = 0; 
  
  }
  
  return ( 0 );
}


