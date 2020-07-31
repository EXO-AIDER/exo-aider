/*
Basic_SPI.ino
Brian R Taylor
brian.taylor@bolderflight.com

Copyright (c) 2017 Bolder Flight Systems

Permission is hereby granted, free of charge, to any person obtaining a copy of this software 
and associated documentation files (the "Software"), to deal in the Software without restriction, 
including without limitation the rights to use, copy, modify, merge, publish, distribute, 
sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is 
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or 
substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING 
BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND 
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#include "MPU9250.h"
#include <Arduino.h>

// an MPU9250 object with the MPU-9250 sensor on SPI bus 0 and chip select pin 10
MPU9250 IMU1(SPI,15);
MPU9250 IMU2(SPI,33);
int status1; 
int status2;

std::vector<float> low_frequency_samples;

void setup() {
  // serial to display data
  Serial.begin(115200);
  while(!Serial) {}

  // start communication with IMU 
  status1 = IMU1.begin();
  status2 = IMU2.begin();
  if (status1 < 0) {
    Serial.println("IMU initialization unsuccessful");
    Serial.println("Check IMU wiring or try cycling power");
    Serial.print("Status: ");
    Serial.println(status1);
    Serial.println(status2);
    while(1) {}
  }
}

void loop() {
  // read the sensor
  IMU1.readSensor();
  IMU2.readSensor();

  low_frequency_samples.push_back(IMU1.getAccelX_mss());
  low_frequency_samples.push_back(IMU1.getAccelY_mss());                                                                  // Reinterprets IMU data float to uint8_t data 
  low_frequency_samples.push_back(IMU1.getAccelZ_mss());                                                                  // Reinterprets IMU data float to uint8_t data 
  low_frequency_samples.push_back(IMU1.getGyroX_rads());                                                                  // Reinterprets IMU data float to uint8_t data 
  low_frequency_samples.push_back(IMU1.getGyroY_rads());                                                                  // Reinterprets IMU data float to uint8_t data 
  low_frequency_samples.push_back(IMU1.getGyroZ_rads());
  low_frequency_samples.push_back(IMU2.getAccelX_mss());
  low_frequency_samples.push_back(IMU2.getAccelY_mss());                                                                  // Reinterprets IMU data float to uint8_t data 
  low_frequency_samples.push_back(IMU2.getAccelZ_mss());                                                                  // Reinterprets IMU data float to uint8_t data 
  low_frequency_samples.push_back(IMU2.getGyroX_rads());                                                                  // Reinterprets IMU data float to uint8_t data 
  low_frequency_samples.push_back(IMU2.getGyroY_rads());                                                                  // Reinterprets IMU data float to uint8_t data 
  low_frequency_samples.push_back(IMU2.getGyroZ_rads());
  // display the data

  for(int i = 0; i < low_frequency_samples.size(); i++)
  {
    Serial.println(low_frequency_samples[i], 6);
  }
  
  delay(100);
}
