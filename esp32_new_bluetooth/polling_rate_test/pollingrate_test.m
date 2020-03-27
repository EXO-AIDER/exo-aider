b = Bluetooth('ESP32',1,'Timeout',3);
fopen(b);

data = fread(b);