function [x, x_actual, y, f_actual, procesing_time] = bluetooth_speed_test(b, number_of_packages, number_of_signals, target_frequency)
%TEST_COMPILED_BLUETOOTH Summary of this function goes here
%   Detailed explanation goes here

    b.flush();
    
    disp('sending!');    
    t_start = posixtime(datetime);
    b.send(['send:' num2str(number_of_packages) ':' num2str(number_of_signals), ':', num2str(target_frequency)]);

    msg_start = b.message_buffer_write_idx;
    while (b.message_buffer_write_idx - msg_start) < number_of_packages
       pause(0.01); 
    end

    idx_to_keep = arrayfun(@(x) ~isempty(x.numbers), b.message_buffer);
    msg_with_error = sum(~idx_to_keep);
    disp(['Messages with error: ' num2str(msg_with_error)]);
    
    x = [b.message_buffer(idx_to_keep).timestamp_recieved] - t_start;
    x_actual = [b.message_buffer(idx_to_keep).timestamp_added] - t_start;
    
    tic;
    y = cell2mat({b.message_buffer(idx_to_keep).numbers}');
    procesing_time = toc;
    
    try
    f_actual = length(x_actual) / (procesing_time + max(x_actual) - min(x_actual));
    catch me
       disp(me); 
    end
    
    disp(['Actual Frequency: ', num2str(f_actual)]);
end

