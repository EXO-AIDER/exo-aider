#pragma once

#include "TaskInterface.h"

struct DemoSensorBandTask : TaskInterface {

  bool is_left_sensor_band;

  DemoSensorBandTask(bool is_left_sensor_band){
    this->is_left_sensor_band = is_left_sensor_band;
  }

  bool initialize(){
    if(is_left_sensor_band){
      description = "Left sensor band";
    } else {
      description = "Right sensor band";
    }
    low_frequency_sample_names = {
      "FSR1", "FSR2", "FSR3", "FSR4", "FSR5", "FSR6", "FSR7", "FSR8",
      "IMU1", "IMU2", "IMU3",
      "GYRO1", "GYRO2", "GYRO3"
    };
    high_frequency_sample_names = {
      "EMG1", "EMG2", "EMG3"
    };
    return true;
  }
  bool process_message(const Message &incomming_message, vector<Message> &outgoing_messages){
      return false;
  }

  bool get_low_frequency_samples(vector<float> &low_frequency_samples, bool sample_frequency){
    for(int i = 0; i < low_frequency_sample_names.size(); i++) 
      low_frequency_samples.push_back(1.0f + (float)i / 100.0f);

    return true;
  }
  bool get_high_frequency_samples(vector<float> &high_frequency_samples, bool sample_frequency){
    for(int i = 0; i < high_frequency_sample_names.size(); i++) 
      high_frequency_samples.push_back(2.0f + (float)i / 100.0f);

    return true;
  }
};