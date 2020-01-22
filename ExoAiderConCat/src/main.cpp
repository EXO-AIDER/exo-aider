#include <Arduino.h>
#include "BluetoothSerial.h" 
#include "TaskBT2.h"
#include <chrono> // used to time loop
int time_avg_count = 0;
double time_avg = 0.0;

#define CS_IMU1 15
#define CS_IMU2 33
#define CS_DAC 32
#define CS_ADC 14

BluetoothSerial ESP_BT; //Object for Bluetooth
TaskBT2 Task(CS_IMU1, CS_IMU2, CS_DAC, CS_ADC);   // pins for IMUs
std::vector<uint8_t> DataBufferBT;

unsigned long dummy1, dummy2;

float SetVoltage = 0;

void setup() { 

  pinMode (LED_BUILTIN, OUTPUT); //Specify LED pin as output

  Serial.begin(230400); //Start Serial monitor in 9600
  Serial.println("");

  Task.BeginIMU();     // Initiate IMU
  Task.BeginDAC();     // Initiate DAC - Default output is set to zero volt
  Task.BeginADC();     // Initiate ADC
  
  /* Example: set DAC voltage channel [0 - 7] - input: [Channel, Voltage] 
     Erase this if not used! */
  Task.SetDACVoltaget(0, SetVoltage); 
  Task.SetDACVoltaget(1, SetVoltage); 
  Task.SetDACVoltaget(2, SetVoltage);
  Task.SetDACVoltaget(3, SetVoltage);
  Task.SetDACVoltaget(4, SetVoltage);
  Task.SetDACVoltaget(5, SetVoltage);
  Task.SetDACVoltaget(6, SetVoltage);
  Task.SetDACVoltaget(7, SetVoltage);
  // Example: Set DAC voltage end 

  // Bluetooth 
  ESP_BT.begin("Exo-Aider ESP32");                                    //Name of Bluetooth Device
  Serial.println("Bluetooth Device is Ready to Pair");
  while(ESP_BT.hasClient() == false){digitalWrite(LED_BUILTIN, LOW);} // Wait until a connection is established
  
  Serial.println("Device Connected"); 
  // Task.TestTask(); // Debugging erase this for
  
}


void loop() {  
  // auto t1 = std::chrono::high_resolution_clock::now();  // timing start

  while(ESP_BT.hasClient() == false){digitalWrite(LED_BUILTIN, LOW);} // Check for client, if non, wait 
  digitalWrite(LED_BUILTIN, HIGH);

  if (ESP_BT.available())                                   // Check for received task over Bluetooth   
  {
    Task.SetTask(ESP_BT.read());                            // Check task to execute
  }
  
  if (Task.RunTask()){                                      // Check if task exsists         
    Task.ExecuteTask();                                     // Execute task 
    DataBufferBT = Task.GetSensorDataBT();                  // Get task/sensor data
    ESP_BT.write(DataBufferBT.data(), DataBufferBT.size()); // Send data over Bluetooth
    
  }


  // Timing duration and printing
  // auto t2 = std::chrono::high_resolution_clock::now(); // timing end  
  // auto duration = std::chrono::duration_cast<std::chrono::microseconds>( t2 - t1 ).count();

  // time_avg += duration;
 
  // if(time_avg_count == 1000){
  //   cout << "Sample frequency: " << 1/((time_avg/1000.0)*0.000001) << " Hz" << endl;
  //   time_avg_count = 0;
  //   time_avg = 0.0;
  // }
  // time_avg_count++;

}

