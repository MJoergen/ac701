/*****************************************************************************
*                                                                            *
* Project              Orca                                                  *
* Module               Driver, IO 1035 header file                           *
*                                                                            *
* Directory            /sources/IO1035                                       *
* Filename             drv_io1035.hpp                                        *
*                                                                            *
* Author               KIE                                                   *
* Date                 2022/09                                               *
*                                                                            *
* Description          IO1035 definitions, in large part based off IO1020    *
*                      FPGA functionality, see corresponding 1020 files.     *
*                                                                            *
* P:\IP\Hardware\PCB10xx\PCB1035\PCB1035-0\FPGA\Doc                          *
*                                                                            *
*****************************************************************************/


#ifndef DRV_IO1035_HPP
#define DRV_IO1035_HPP

/* Standard libraries */
#include <stdio.h>
#include <stdbool.h>
#include <stdint.h>

int load1035Fpga           ( char* buf, int nbytes );
int load1035FpgaNoDma      ( char* buf, int nbytes );

/* Definitions */
#define  IO1035_scratchPad          (0x00/4)
#define  IO1035_version             (0x04/4)
#define  IO1035_compileTime         (0x08/4)
#define  IO1035_control             (0x0C/4)
#define  IO1035_sysClkCntLatch      (0x10/4)
#define  IO1035_intState            (0x14/4)
#define  IO1035_intMask             (0x18/4)
#define  IO1035_setTime             (0x1C/4)
#define  IO1035_timeControl         (0x20/4)
#define  IO1035_localTimeHigh       (0x24/4)
#define  IO1035_localTimeLow        (0x28/4)
#define  IO1035_refClkCntLatch      (0x2C/4)

#define  IO1035_servoIrqRate        (0x30/4)
#define  IO1035_servoIrqControl     (0x34/4)
#define  IO1035_servoIrqTimeHigh    (0x38/4)
#define  IO1035_servoIrqTimeLow     (0x3C/4)
#define  IO1035_triggerTimeHigh     (0x40/4)
#define  IO1035_triggerTimeLow      (0x44/4)
#define  IO1035_sIrqDSsi            (0x48/4)
#define  IO1035_bissIrq             (0x58/4)
#define  IO1035_tachoStatus         (0x64/4)
#define  IO1035_tachoAz1Cnt         (0x80/4)
#define  IO1035_tachoAz1IrqCnt      (0x84/4)
#define  IO1035_tachoAz1RefCnt      (0x88/4)
#define  IO1035_tachoAz2Cnt         (0x8C/4)
#define  IO1035_tachoAz2IrqCnt      (0x90/4)
#define  IO1035_tachoAz2RefCnt      (0x94/4)
//#define  IO1035_safe                (0x98/4) // unused in 1035
//#define  IO1035_gpioData            (0x9C/4) // unused in 1035
#define  IO1035_gpioDir             (0xA0/4)
#define  IO1035_perifSel            (0xA8/4)
#define  IO1035_timeout             (0xAC/4)

#define  IO1035_PPS_100M            (0x10000/4)
#define  IO1035_TIMING              (0x10004/4)
#define  IO1035_SAFETY              (0x10008/4)
#define  IO1035_MAST                (0x1000C/4)
#define  IO1035_PIN_LOCK            (0x10010/4)
#define  IO1035_MOTOR_DRIVE         (0x10014/4)
#define  IO1035_POWER_MODE          (0x10018/4)
#define  IO1035_RCU                 (0x1001C/4)
#define  IO1035_SYS                 (0x10020/4)
#define  IO1035_INT                 (0x10024/4)
#define  IO1035_RCU_FAN_RPM0        (0x10028/4)
#define  IO1035_RCU_FAN_RPM1        (0x1002C/4)
#define  IO1035_RCU_FAN_RPM2        (0x10030/4)
#define  IO1035_RCU_FAN_RPM3        (0x10034/4)
#define  IO1035_RCU_FAN_RPM4        (0x10038/4)
#define  IO1035_RCU_FAN_RPM5        (0x1003C/4)
#define  IO1035_RCU_FAN_SPEED       (0x10040/4)
#define  IO1035_POWER_MONITOR       (0x10044/4)
#define  IO1035_POWER_MONITOR_PSU   (0x10048/4)

#define  IO1035_CHIP_ID             (0x10060/4)

#define  IO1035_IFF_MESSAGE_RATE    (0x10100/4)
#define  IO1035_IFF_ENC_OFFSET      (0x10104/4)
#define  IO1035_IFF_DATA            (0x10108/4)
#define  IO1035_IFF_CTRL            (0x1010C/4)
#define  IO1035_IFF_STATUS          (0x10110/4)

/* Safety FPGA */
#define  IO1035_SFT_TRANSMIT_LIMIT  (0x10300/4)
#define  IO1035_TRANSMIT_ZONE_COUNT (16)

#define  IO1035_SFT_TIMESTAMP       (0x10380/4)
#define  IO1035_SFT_CHIP_ID         (0x10384/4)
#define  IO1035_SFT_CHIP_VERSION    (0x10388/4)
#define  IO1035_SFT_ENC_VALUE       (0x10390/4)
#define  IO1035_SFT_BISS_STATUS     (0x10394/4)
#define  IO1035_SFT_LIMIT_EN        (0x10398/4)
#define  IO1035_SFT_BISS_IF         (0x1039C/4)
#define  IO1035_SFT_AZIMUTH_OFFSET  (0x103A0/4)
#define  IO1035_SFT_AZIMUTH_ENABLE  (0x103A4/4)
#define  IO1035_SFT_BLOCKING_LIMIT  (0x103B0/4)
#define  IO1035_BLOCKING_ZONE_COUNT (10)


/* Main FPGA again */
#define IO1035_PARKLOCK_POS1         (0x10400/4)
#define IO1035_PARKLOCK_POS2         (0x10404/4)
#define IO1035_PARKLOCK_POS3         (0x10408/4)
#define IO1035_PARKLOCK_POS4         (0x1040C/4)

#define IO1035_PARKLOCK_CALIBRATION1 (0x10410/4)
#define IO1035_PARKLOCK_CALIBRATION2 (0x10414/4)
#define IO1035_PARKLOCK_CALIBRATION3 (0x10418/4)
#define IO1035_PARKLOCK_CALIBRATION4 (0x1041C/4)

#define IO1035_PARKLOCK_TOLERANCE    (0x10420/4)
#define IO1035_PARKLOCK_ENABLEMASK   (0x10424/4)
#define IO1035_PARKLOCK_CUR_POSITION (0x10428/4)
#define IO1035_PARKLOCK_STATUS       (0x1042C/4)


/* REG_SAFETY 0x10008 */
#define SAFE_SAFETY_EN          BIT0
#define SAFE_TXON               BIT1
#define SAFE_POWERREDUCE        BIT2
#define SAFE_BEAMENABLE         BIT3
#define SAFE_EMS_EXT            BIT4
#define SAFE_MOT_PANEL          BIT5
#define SAFE_TX_PANEL           BIT6
#define SAFE_EMS_PANEL          BIT7
#define SAFE_EMS_MAINTENANCE    BIT8
#define SAFE_TX_EXT             BIT9
#define SAFE_MOT_EXT            BIT10
#define SAFE_MOTOR_STO          BIT11
#define SAFE_TX_READY           BIT12
#define SAFE_SAFETY_PGN         BIT13
#define SAFE_SAFETY_FLAG        BIT14
#define SAFE_TRANSMITZONE       BIT15
#define SAFE_IFF_EMCON          BIT16

/* REG_MOTOR_DRIVE 0x10014 */
#define IO1035_ENABLE_SERVO       BIT0
#define IO1035_MOTORDRIVER_GPO2   BIT1
#define IO1035_MOTORDRIVER_GPO3   BIT2
#define IO1035_MOTORDRIVER_GPO4   BIT3
#define IO1035_MOTORDRIVER_GPO5   BIT4
#define IO1035_MOTORDRIVER_GPO6   BIT5

//#define DISPLAYKEY_ONOFF      0
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



/* Mast control */
#define IO1035_MAST_ABOVE_MID        BIT0
#define IO1035_MAST_BELOW_MID        BIT1
#define IO1035_MAST_RETRACTED        BIT2
#define IO1035_MAST_NOT_RETRACTED    BIT3
#define IO1035_MAST_EXTENDED         BIT4
#define IO1035_MAST_NOT_EXTENDED     BIT5

/* IO1035 ADC readouts: Temperature, voltage, current, duty cycle, frequency, fan speed */

/* Temperature:
 * 0: Kontron 0           VxImg 
 * 1: Kontron 1           VxImg 
 * 2: Ericsson 48DC-DC12  I2C   
 * 3: 3V3 TempSense       SPI   
 * 4: 5V5 TempSense       SPI   
 * 5: 24V TempSense       SPI   
 * 6: LSM6DSM             I2C
 * 7: MT_KTY              SPI + I2C
 * 8: MT_PTC              SPI + I2C
 */
#define IO1035_ADC_TEMPERATURE_COUNT  9
#define IO1035_ADC_TEMPERATURE_TYPE   0

/* Voltage:
 * 
 * SPI AD7327
 * 0: VMOT_SE
 * 1: D3V3_MOT
 * 2: A5V0_MOT
 * 3: REF_6V
 * 4: AP11V_MOT/2
 * 5: AN11V_MOT/2
 * 6: GND
 * 7: REF
 * 
 * SPI AD7327
 * 8:  REF
 * 9:  MT_KTY (also temperature)
 * 10: MT_PTC (also temperature)
 * 11: 2V5
 * 12: 3V3_TempSense (also temperature)
 * 13: 5V5_TempSense (also temperature)
 * 14: 24V_TempSense (also temperature)
 * 15: GND
 * 
 * I2C INA233's
 * 16: 3V3
 * 17: 5V5
 * 18: 1V5
 * 19: 2V5
 * 20: 1V2
 * 21: 24V
 * 
 * I2C 48DC-DC12
 * 22: VIN
 * 23: VOUT
 */
#define IO1035_ADC_VOLTAGE_COUNT      24
#define IO1035_ADC_VOLTAGE_TYPE       1

/* Current:
 * 
 * I2C INA233's
 * 0: U754
 * 1: U755
 * 2: U761
 * 3: U763
 * 4: U765
 * 5: U769
 * 
 * I2C 48DC-DC12
 * 6: IOUT
 */
#define IO1035_ADC_CURRENT_COUNT      7
#define IO1035_ADC_CURRENT_TYPE       2

/* Duty cycle:
 * 
 * I2C 48DC-DC12
 */
#define IO1035_ADC_DUTY_CYCLE_COUNT   1
#define IO1035_ADC_DUTY_CYCLE_TYPE    3
#define IO1035_ADC_DUTY_CYCLE_OFFSET  IO1035_ADC_TEMPERATURE_COUNT +\
                                      IO1035_ADC_VOLTAGE_COUNT     +\
                                      IO1035_ADC_CURRENT_COUNT

/* Frequency:
 * 
 * I2C 48DC-DC12
 */
#define IO1035_ADC_FREQUENCY_COUNT    1
#define IO1035_ADC_FREQUENCY_TYPE     4

/* Fan speed:
 * 
 * Six RCU fans
 */
#define IO1035_ADC_FANSPEED_COUNT     6
#define IO1035_ADC_FANSPEED_TYPE      5

/* IMU acceleration and gyroscope
 * 
 * I2C LSM6DSM
 * 0: Temperature
 * 1: Gyroscope X
 * 2: Gyroscope Y
 * 3: Gyroscope Z
 * 4: Acceleration X
 * 5: Acceleration Y
 * 6: Acceleration Z
 */
#define IO1035_ADC_IMU_COUNT          7
#define IO1035_ADC_IMU_TYPE           6

#define IO1035_ADC_TYPE_COUNT         7



#endif // DRV_IO1035_HPP


