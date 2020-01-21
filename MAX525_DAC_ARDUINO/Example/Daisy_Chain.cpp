/*  This is for a two stage Daisy-Chain configuration of the MAX525 DAC. 
    If only one MAX525 is used, use the function SetVoltage(int DAC_x, float Voltage) instead*/

#include <Arduino.h>
#include <MAX525.h>

uint8_t CS_DAC = 14;
MAX525 DAC525(SPI, CS_DAC);

void setup() {
  Serial.begin(9600);
  DAC525.begin();
}

void loop() {
   DAC525.SetVoltage_Daisy(0,1);  // Set DAC channel A on DAC_0 to one volt 
   delay(1000);
   DAC525.SetVoltage_Daisy(1,1);  // Set DAC channel B on DAC_0 to one volt 
   delay(1000);
   DAC525.SetVoltage_Daisy(2,1);  // Set DAC channel C on DAC_0 to one volt 
   delay(1000);
   DAC525.SetVoltage_Daisy(3,1);  // Set DAC channel D on DAC_0 to one volt 
   delay(1000);
   DAC525.SetVoltage_Daisy(4,1);  // Set DAC channel A on DAC_1 to one volt
   delay(1000); 
   DAC525.SetVoltage_Daisy(5,1);  // Set DAC channel B on DAC_0 to one volt
   delay(1000); 
   DAC525.SetVoltage_Daisy(6,1);  // Set DAC channel C on DAC_0 to one volt
   delay(1000); 
   DAC525.SetVoltage_Daisy(7,1);  // Set DAC channel D on DAC_0 to one volt
   delay(1000); 
}