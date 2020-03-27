#include "BluetoothSerial.h"
 
BluetoothSerial SerialBT;
 
void callback(esp_spp_cb_event_t event, esp_spp_cb_param_t *param){
  if(event == ESP_SPP_SRV_OPEN_EVT){
    Serial.println("Client Connected");
  }
}
 
void setup() {
  Serial.begin(115200);
 
  SerialBT.register_callback(callback);
 
  if(!SerialBT.begin("ESP32")){
    Serial.println("An error occurred initializing Bluetooth");
  }else{
    Serial.println("Bluetooth initialized");
  }
}

uint32_t starttime = micros();
 
void loop() {
  uint8_t time = millis() - starttime;
  Serial.println(time);
  SerialBT.write(&time, sizeof(time));
}