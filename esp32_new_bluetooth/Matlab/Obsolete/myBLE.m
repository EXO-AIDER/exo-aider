classdef myBLE < handle
    %MYBLUETOOTH Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        server_name
        server_uuid
        tx_characteristic_uuid
        rx_characteristic_uuid
        timeout = 3.0
        
        server        
        tx_characteristic
        rx_characteristic
        
        message_buffer
        message_buffer_read_idx
        message_buffer_write_idx
    end
    
    methods
        function obj = myBLE(server_name, server_uuid, tx_characteristic_uuid, rx_characteristic_uuid)
            obj.server_name = server_name;
            obj.server_uuid = server_uuid;
            obj.tx_characteristic_uuid = tx_characteristic_uuid;
            obj.rx_characteristic_uuid = rx_characteristic_uuid;
            
            obj.initialize_buffer;
            
            obj.reconnect;
        end
             
        function result = ensure_connected(obj)
            result = true;
           if ~obj.server.Connected
               try
                obj.reconnect;
               catch
                warning('Could not connect to device!');   
               end
               result = false;
           end
        end
        
        function reconnect(obj)
            if ~isempty(obj.server)
                obj.server = [];
                obj.tx_characteristic = [];
                obj.rx_characteristic = [];
            end
            
            obj.server = ble(obj.server_name); % Throws error if it does not exist
            
            service_uuids = obj.server.Characteristics.ServiceUUID;
            characteristic_uuids = obj.server.Characteristics.CharacteristicUUID;
            
            has_rx_character = any(service_uuids == obj.server_uuid & characteristic_uuids == obj.rx_characteristic_uuid);
            has_tx_character = any(service_uuids == obj.server_uuid & characteristic_uuids == obj.tx_characteristic_uuid);

            if ~has_rx_character || ~has_tx_character
                error('Could not find expected characteristic!');
            end
            
            obj.tx_characteristic = characteristic(obj.server, obj.server_uuid, obj.tx_characteristic_uuid);
            obj.rx_characteristic = characteristic(obj.server, obj.server_uuid, obj.rx_characteristic_uuid);
            
            obj.rx_characteristic.DataAvailableFcn = @(src, event) obj.read_callback(src, event);
        end
        
        function initialize_buffer(obj, buffer_size)
           if nargin == 1
              buffer_size = 1000; 
           end
           obj.message_buffer = repmat(Message(), 1, buffer_size);
           obj.flush;
        end

        function x = messages_availiable(obj)
            x = obj.message_buffer_write_idx - obj.message_buffer_read_idx;
        end
        
        function add_message_to_buffer(obj, message)
            n = length(obj.message_buffer);
            idx = 1 + mod(obj.message_buffer_write_idx, n);
            
            obj.message_buffer(idx) = message;
            
            obj.message_buffer_write_idx = obj.message_buffer_write_idx + 1;
            if obj.message_buffer_read_idx + n < obj.message_buffer_write_idx
                %warning('Buffer overflow!');
                obj.message_buffer_read_idx = obj.message_buffer_write_idx - n;
            end
        end
        
        function message = get_next_message(obj)
            if ~obj.ensure_connected
                message = [];
                return
            end
            n = length(obj.message_buffer);
            idx = 1 + mod(obj.message_buffer_read_idx, n);

            if obj.message_buffer_read_idx >= obj.message_buffer_write_idx
               error('No availiable messages!');
            end
            message = obj.message_buffer(idx);
            
            obj.message_buffer_read_idx = obj.message_buffer_read_idx + 1;
        end
        
        function test_buffer(obj)
            n = 10;
            m = 4;
           obj.initialize_buffer(n);
           
           if obj.messages_availiable ~= 0
               error('Incorrect number of messages!');
           end
           
           for i = 1:n+m
                obj.add_message_to_buffer(i, i);
                if obj.messages_availiable ~= min([i, 10])
                    error('Incorrect number of messages!');
                end
           end
           
           for j = 1+m:m+n
               msg = obj.get_next_message;
               if msg.timestamp_recieved ~= j
                  error('Unexpected timestamp_recived!'); 
               end
           end
           
           err = false;
           try
              obj.get_next_message
              err = true;
           catch em
           end
           if err
              error('Should throw error!'); 
           end
        end
        
        function send(obj, command, numbers)
            if ~obj.ensure_connected
                return
            end
            if nargin < 3
                data = [uint8(command), 0];
            else
                data = [uint8(command), 0, typecast(single(numbers), 'uint8')];
            end
            obj.tx_characteristic.write(data, 'uint8');
        end
        
        function read_callback(obj, src, event)            
            data = uint8(obj.rx_characteristic.read("oldest"));
            t_received = posixtime(datetime);
            
            command_terminator_idx = find(data==0, 1);
            if mod(length(data(command_terminator_idx+1:end)), 4) ~= 0
               warning(['Got invalid data: [', num2str(data), ']']);
               return;
            end
            command = char(data(1:command_terminator_idx-1));
            numbers = double(typecast(data(command_terminator_idx+1:end), 'single'));
            
            new_message = Message(command, numbers, t_received);
            obj.add_message_to_buffer(new_message);
            
            %obj.messages{end+1} = data;
            %obj.message_timestamps(end+1) = posixtime(datetime(event.Data.AbsTime));
            %obj.message_timestamps_actual(end+1) = posixtime(datetime);
            %disp(['Got: ', data]);
        end
                
        function sucess = wait_for_x_messages(obj, number_of_messages)
            start = tic;
            while obj.messages_availiable < number_of_messages
                if obj.timeout < toc(start)
                    sucess = false;
                    return;
                end
                pause(1e-3);
            end
            sucess = true;
        end
        
        function sucess = wait_for_any_message(obj)
            sucess = obj.wait_for_x_messages(1);
        end
        
        function sucess = wait_for_new_message(obj)
            sucess = obj.wait_for_x_messages(obj.messages_availiable + 1);
        end
        
        function flush(obj)
           obj.message_buffer_read_idx = 0;
           obj.message_buffer_write_idx = 0;
        end
        
        function q = query(obj, command, numbers)
            q = [];
            if nargin == 3
                obj.send(command, numbers);
            else
                obj.send(command);
            end
            t = tic;
            while toc(t) < obj.timeout
                if 0 < obj.messages_availiable
                    msg = obj.get_next_message;
                    if strcmp(msg.command, command)
                        q = msg;
                        return
                    end
                end
                pause(0.001);
            end
        end
                
        function [mean_latancy, std_latancy, latancy_arr] = estimate_latancy(obj, num_times)
            if nargin < 2
                num_times = 20;
            end
            latancy_arr = zeros(1, num_times);
            
            for i = 1:num_times
                obj.flush;
                t_start = posixtime(datetime);
                msg = obj.query('ping');
                if isempty(msg)
                   mean_latancy = nan;
                   std_latancy = nan;
                   latancy_arr = latancy_arr * nan;
                   return;
                end
                latancy_arr(i) = (msg.time_received - t_start)/2;
                pause(2 * latancy_arr(i));
            end
            mean_latancy = mean(latancy_arr);
            std_latancy = std(latancy_arr);
            
            if nargout == 0
               disp(['Latancy analysis of ' num2str(num_times) ' experiments.']); 
               disp([' * mean: ' num2str(mean_latancy*1e3), ' ms']);
               disp([' * std:  ' num2str(std_latancy*1e3), ' ms']);
            end
        end
        
    end
end

