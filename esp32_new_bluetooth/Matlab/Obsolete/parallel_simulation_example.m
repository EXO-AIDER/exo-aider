clear all

SERVER_NAME = 'Exo-Aider ESP32';
SERVICE_UUID = '6E400001-B5A3-F393-E0A9-E50E24DCCA9E';
CHARACTERISTIC_UUID_TX = '6E400002-B5A3-F393-E0A9-E50E24DCCA9E';
CHARACTERISTIC_UUID_RX = '6E400003-B5A3-F393-E0A9-E50E24DCCA9E';

BT = myBLE(SERVER_NAME, SERVICE_UUID, CHARACTERISTIC_UUID_TX, CHARACTERISTIC_UUID_RX);

BT.query('ping')

BT.estimate_latancy

return;
server = ble('Exo-Aider ESP32');

service_uuids = server.Characteristics.ServiceUUID;
characteristic_uuids = server.Characteristics.CharacteristicUUID;

has_rx_character = any(service_uuids == SERVICE_UUID & characteristic_uuids == CHARACTERISTIC_UUID_RX);
has_tx_character = any(service_uuids == SERVICE_UUID & characteristic_uuids == CHARACTERISTIC_UUID_TX);

if ~has_rx_character || ~has_tx_character
    error('Could not find expected characteristic!');
    return;
end

tx_characteristic = characteristic(server, SERVICE_UUID, CHARACTERISTIC_UUID_TX);
rx_characteristic = characteristic(server, SERVICE_UUID, CHARACTERISTIC_UUID_RX);
subscribe(rx_characteristic);

ping_cmd = [uint8('ping'), 0];
tx_characteristic.write(ping_cmd, 'uint8')
