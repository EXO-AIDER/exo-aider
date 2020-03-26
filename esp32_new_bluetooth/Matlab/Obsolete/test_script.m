clc; clear all; delete(instrfind)
% Note: Please pair the BT with Windows before running this script:
% Windows start button -> Bluetooth & other devices -> Enable Bluetooth and
% pair with ESP32..
%
% Troubleshooting https://se.mathworks.com/help/instrument/troubleshooting-bluetooth-interface.html

%% Include path 
addpath(genpath('Functions'));
addpath(genpath('Data'));

%% Create BT connection to ESP32
% It might be a good idea to restart matlab if the BT connection has been
% established before and was not properly disconnected!
% call:: restart_matlab()

N = 10;

b = myBluetooth('Exo-Aider ESP32');

%%
count_to = 10000;

for i = 1:10
    disp(['Start - ', num2str(i)]);
    b.flush();
    tic;
    t_start = posixtime(datetime);
    b.send('send');
    
    while b.get_number_of_messages < count_to
       pause(0.01); 
    end
    toc;
    elapsed_time = toc;
    
    figure(1);
    x = b.message_timestamps - t_start;
    x_actual = b.message_timestamps_actual - t_start;
    y = cellfun(@(x) str2double(char(x)), b.messages);
    f = length(x) / elapsed_time;
    plot(x, y, x_actual, y);
    title(['Frequency: ', num2str(f)]);
    drawnow;
    pause(1);
end

what_to_send = 'This is the shit!';




if true
    
    b.flush;
    
    for i = 1:100
        disp(i);
        for j = 1:3
           b.send([what_to_send, '#' num2str(j)]);
        end

        for j = 1:3
           if ~b.wait_for_any_message
               error('Recieved incorrect number of messages!');
           end
           
           message = b.get_next_message;
           if ~strcmp(char(message), [what_to_send, '#', num2str(j)])
               error('Recieved incorrect message content');
           end
        end
        
        really_long_message = repmat(what_to_send, 1, 14);
        b.send(really_long_message);
        b.wait_for_any_message;
        long_message = b.get_next_message;
        if ~strcmp(char(long_message), really_long_message)
           error('Recieved incorrect message content of long messages!'); 
        end
    end
else
    tic;
    if 0 < b.BytesAvailable
        fread(b, b.BytesAvailable); % Flush
    end
    for i = 1:N
        enc_msg = cobs(uint8(what_to_send));
        fwrite(b, enc_msg);

        while b.BytesAvailable < length(what_to_send)
        end

        r = fread(b, length(what_to_send));
        r_char = char(r)';
        if ~strcmp(r_char, what_to_send)
           error('Incorrect return!'); 
        end

        %disp(char(r)');
    end
    time_per_execution = toc/N;
    frequency = 1/time_per_execution;
    time_per_execution
    frequency

end


function send_bluetooth_message(b, data)
    disp(['Sending: ', data]);
    encoded_message = [cobs(uint8(data)), 0];
    fwrite(b, encoded_message);
end

function mesages = recieve_bluetooth_messages(b)
    persistent data
   
    mesages = {};
    bytes_availiable = b.BytesAvailable;
    if 0 < bytes_availiable
        new_data = fread(b, bytes_availiable)';
        data = [data, new_data];
        end_of_message_indexes = find(data==0);
        start_of_message_index = 1;
        for end_of_message_index = end_of_message_indexes
            mesages{end+1} = cobsi(data(start_of_message_index:end_of_message_index-1));
            disp(['Got: ', char(mesages{end})]);
            start_of_message_index = end_of_message_index + 1;
        end
        data = data(start_of_message_index+1:end);
    end
end