/*  Only one MAX525 DAC in use */

#include <Arduino.h>
#include <MAX525.h>

uint8_t CS_DAC = 14;
MAX525 DAC525(SPI, CS_DAC);

void setup() {
  Serial.begin(9600);
  DAC525.begin();
}

void loop() {
   DAC525.SetVoltage(0,1);  // Set DAC channel A on DAC_0 to one volt 
   delay(1000);
   DAC525.SetVoltage(1,1);  // Set DAC channel B on DAC_0 to one volt 
   delay(1000);
   DAC525.SetVoltage(2,1);  // Set DAC channel C on DAC_0 to one volt 
   delay(1000);
   DAC525.SetVoltage(3,1);  // Set DAC channel D on DAC_0 to one volt 
   delay(1000);
}