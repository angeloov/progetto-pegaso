#include <Arduino.h>
#include <Wire.h>
#include <vl53l5cx_class.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <assert.h>
#include <stdlib.h>

#define DEV_I2C Wire1
#define SerialPort Serial

#define LedPin 13

#define LPN_PIN 5
#define I2C_RST_PIN 3
#define PWREN_PIN A3

// Components.
VL53L5CX sensor_vl53l5cx_top(&DEV_I2C, LPN_PIN, I2C_RST_PIN);

void blink_led_loop(void)
{
  do {
    // Blink the led forever
    digitalWrite(LedPin, HIGH);
    delay(500);
    digitalWrite(LedPin, LOW);
  } while (1);
}

/* Setup ---------------------------------------------------------------------*/

void setup()
{
  // Led.
  pinMode(LedPin, OUTPUT);

  // Enable PWREN pin if present
  if (PWREN_PIN >= 0) {
    pinMode(PWREN_PIN, OUTPUT);
    digitalWrite(PWREN_PIN, HIGH);
    delay(10);
  }

  // Initialize serial for output.
  SerialPort.begin(115200);
  SerialPort.println("Initialize... Please wait, it may take few seconds...");

  // Initialize I2C bus.
  DEV_I2C.begin();

  // Configure VL53L5CX component.
  sensor_vl53l5cx_top.begin();

  sensor_vl53l5cx_top.init_sensor();

  // Start Measurements
  sensor_vl53l5cx_top.vl53l5cx_start_ranging();
}

void loop()
{
  static uint8_t loop_count = 0;
  VL53L5CX_ResultsData Results;
  uint8_t NewDataReady = 0;
  char report[64];
  uint8_t status;

  if (loop_count < 500) {

    do {
      status = sensor_vl53l5cx_top.vl53l5cx_check_data_ready(&NewDataReady);
    } while (!NewDataReady);

    // Led on
    digitalWrite(LedPin, HIGH);

    if ((!status) && (NewDataReady != 0)) {
      status = sensor_vl53l5cx_top.vl53l5cx_get_ranging_data(&Results);

      /* As the sensor is set in 4x4 mode by default, we have a total
       * of 16 zones to print.
       */

      /*
      snprintf(report, sizeof(report), "Print data no : %3u\r\n", sensor_vl53l5cx_top.get_stream_count());
      SerialPort.print(report);
      for (int i = 0; i < 16; i++) {
        snprintf(report, sizeof(report), "Zone : %3d, Status : %3u, Distance : %4d mm\r\n",
                 i,
                 Results.target_status[VL53L5CX_NB_TARGET_PER_ZONE * i],
                 Results.distance_mm[VL53L5CX_NB_TARGET_PER_ZONE * i]);
        SerialPort.print(report);
      }
      SerialPort.println("");
      */

      for (int i = 0; i < 16; i++) {
        SerialPort.print(Results.distance_mm[VL53L5CX_NB_TARGET_PER_ZONE * i]);
        SerialPort.print(" ");

        if ((i+1) % 4 == 0) {
          SerialPort.println(); 
        }
      }
      
      Serial.print("\n\n");
      
      loop_count++;
    }

    digitalWrite(LedPin, LOW);
  } else if (loop_count == 500) {
    /* Stop measurements */
    status = sensor_vl53l5cx_top.vl53l5cx_stop_ranging();
    
    if (status) {
      snprintf(report, sizeof(report), "vl53l5cx_stop_ranging failed, status %u\r\n", status);
      SerialPort.print(report);
      blink_led_loop();
    }

    loop_count++;

    /* End of the demo */
    SerialPort.println("End of ULD demo");
  } else {
    delay(1000);
  }
}
