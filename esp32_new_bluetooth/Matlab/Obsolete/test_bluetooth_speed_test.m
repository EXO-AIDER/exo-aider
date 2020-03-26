clear all;


%% Bluetooth connection
clear BT_left_sensor_band BT_right_sensor_band BT_motor_controller
delete(instrfind);

bluetooth_motor_controller_name =  'Exo-Aider@009ABBE350CC';
bluetooth_left_sensor_band_name =  'Exo-Aider@74E80B12CFA4';
bluetooth_right_sensor_band_name = 'Exo-Aider@60FB9912CFA4';

signal_buffer = 5000*10;
motor_controller_low_frequency_signals = 20 + 2;
motor_controller_high_frequency_signals = 0;
sensor_band_low_frequency_signals = 6 + 2;
sensor_band_high_frequency_signals = 11;

sensor_band_low_frequency_signals = 6 + 2 + 8;
sensor_band_high_frequency_signals = 11 - 8;

BT_motor_controller = connect_to_device(bluetooth_motor_controller_name, 0, 'motor controller');
BT_left_sensor_band = connect_to_device(bluetooth_left_sensor_band_name, 1, 'left sensor band');
BT_right_sensor_band = connect_to_device(bluetooth_right_sensor_band_name, 2, 'right sensor band');

disp('Connection done!');

%%
% Configure the 
sample_frequency = 1000;
send_frequency = 50;

window_in_seconds = 20;
reference_frequency = window_in_seconds/4;
update_plot_every_x_seconds = 1;
calculation_time = 5 * 1e-3;

additional_signals = 0;

low_frequency_ratio = floor(sample_frequency/send_frequency);
disp(['Low frequency: ', num2str(sample_frequency/low_frequency_ratio), ' - ratio: ', num2str(low_frequency_ratio)]);
buffer_size = ceil(window_in_seconds*send_frequency);

t_n_first = [];
t_n = zeros(1, buffer_size);
t_a_n = zeros(1, buffer_size);
r_n = zeros(1, buffer_size);
y_n = zeros(1, buffer_size);
u_n = zeros(1, buffer_size);
n_writing = -1;
n_reading = -1;

y_n_playout = [];
t_n_last_playout = 0;

u_integrator = 0;

r_local = 0;

% Reset the devices
if ~isempty(BT_motor_controller)
    BT_motor_controller.query('set_send_signals', false);
    BT_motor_controller.send('set_sample_frequency', sample_frequency);
    BT_motor_controller.send('set_low_frequency_ratio', low_frequency_ratio);
    BT_motor_controller.initialize_signal_buffer(...
        'mc_sig', signal_buffer, motor_controller_low_frequency_signals, ...
        motor_controller_high_frequency_signals, low_frequency_ratio);
end
if ~isempty(BT_left_sensor_band)
    BT_left_sensor_band.query('set_send_signals', false);
    BT_left_sensor_band.send('set_sample_frequency', sample_frequency);
    BT_left_sensor_band.send('set_low_frequency_ratio', low_frequency_ratio);
    BT_left_sensor_band.initialize_signal_buffer(...
        'sb_sig', signal_buffer, sensor_band_low_frequency_signals, ...
        sensor_band_high_frequency_signals, low_frequency_ratio);
end
if ~isempty(BT_right_sensor_band)
    BT_right_sensor_band.query('set_send_signals', false);
    BT_right_sensor_band.send('set_sample_frequency', sample_frequency);
    BT_right_sensor_band.send('set_low_frequency_ratio', low_frequency_ratio);
    BT_right_sensor_band.initialize_signal_buffer(...
        'sb_sig', signal_buffer, sensor_band_low_frequency_signals, ...
        sensor_band_high_frequency_signals, low_frequency_ratio);
end

% Test area
if false
    BT_motor_controller.flush;

    a_in = 1:20;
    b_in = 2:21;

    BT_motor_controller.add_signal_to_buffer(a_in);
    BT_motor_controller.add_signal_to_buffer(a_in);
    for i = 1:size(BT_motor_controller.signal_buffer,1)-2
        BT_motor_controller.add_signal_to_buffer(b_in);
        a_out1 = BT_motor_controller.get_signals(1);
        assert(all(all(a_out1 == a_in)));
        a_outi = BT_motor_controller.get_signals(i);
    end
    BT_motor_controller.add_signal_to_buffer(b_in);
    err = false;
    try
       BT_motor_controller.get_signals(1)
       err = true;
    catch
    end
    assert(err == false);
    %b_out = BT_motor_controller.get_signals(1:2);
    a_out2 = BT_motor_controller.get_signals(2);
    assert(all(all(a_out2 == a_in)));
    disp('done');
end

if false
    BT_motor_controller.query('set_send_signals', true);
    pause(1);
    BT_motor_controller.query('set_send_signals', false);
    
   return 
end
%
if false
    BT_left_sensor_band.add_signal_to_buffer(...
        1:BT_left_sensor_band.signal_low_frequency_length + BT_left_sensor_band.signal_high_frequency_length * 10);
    
    
    BT_left_sensor_band.query('set_send_signals', true);
    pause(1);
    BT_left_sensor_band.query('set_send_signals', false);
    return;
end

% Configure the devices
disp('Determining the playout buffer size..');
BT_devices = [BT_motor_controller, BT_left_sensor_band, BT_right_sensor_band];
for BT_device = BT_devices
    BT_device.query('set_send_signals', true);
end
BT_devices_latancy = [];
for BT_device = BT_devices
    BT_device.flush;
    BT_device.query('set_send_signals', false);
    
    [mean_latancy, std_latancy, ~] = BT_device.estimate_latancy;
    BT_devices_latancy(end+1) = ceil((mean_latancy + std_latancy * 3) * send_frequency);
    
    BT_device.query('set_send_signals', true);
    BT_device.flush;
end
playout_sample_delay = max(BT_devices_latancy);
disp(['Playout buffer size: ', num2str(playout_sample_delay)]);

for BT_device = BT_devices
    BT_device.query('set_send_signals', true);
end
for BT_device = BT_devices
    BT_device.flush;
end

global run_state
run_state = true;
stop_button_handle = [];

t_start = tic;
t_last = toc(t_start);

n_plot_updates = 0;
n_plot_writing_last = 0;
n_reading = 0;
n = 0;

while run_state  
    n = n + 1;
    
    % Take care of sheduling
    t_now = toc(t_start);
    t_next = t_last + 1 / send_frequency;
    t_wait = t_next - t_now;
    if 0 < t_wait
        pause(t_wait);
        t_last = t_next;
    else
        t_last = toc(t_start); 
        disp('Csan''t keep up!');
    end

    % Is there something to act on?
    t_process_start = tic;
    n_writing = BT_motor_controller.signal_n;
    if n_writing < 1
       
    elseif n_writing <= n_reading
        %disp('Read buffer empty!'); 
       
    else % update samples
        n_plot_updates = n_plot_updates + 1;

        n_reading = max([n_reading + 1, n_writing - playout_sample_delay - 1]);
        
        % Calculate reference:
        y_n = BT_motor_controller.get_low_frequency_signals(n_writing, 4);
        t_n = BT_motor_controller.get_low_frequency_signals(n_writing, 2);
        r_local = calculate_reference(t_n, reference_frequency);
        
        e = r_local - y_n;
        u_integrator = u_integrator + e / send_frequency;

        u_input = e * 20 + u_integrator * 2;
        %u_input = e * 8 + u_integrator * 4;
        
        u_input = min([max([u_input, -100]), 100]); % Input saturation
        BT_motor_controller.send('u', u_input);
    end
    
    % Performance calculation
    if mod(n, ceil(send_frequency*update_plot_every_x_seconds)) == 0
        nan_percentage = 100*sum(isnan(r_n)) / length(r_n);
        update_message_ratio = (n_plot_updates-n_plot_writing_last)/(n_writing-n_plot_writing_last);
        
        % Calculate control performance
        n_writing_to = n_writing; 
        n_writing_from = max([n_writing_to - send_frequency*window_in_seconds, 1]); 
        sigs_all = BT_motor_controller.signal_buffer;
        sigs = BT_motor_controller.get_low_frequency_signals(n_writing_from:n_writing_to);
                
        t_n = sigs(:, 2);
        r_n = calculate_reference(t_n, reference_frequency);
        u_n = sigs(:, 3);
        y_n = sigs(:, 4);
        
        diff_r_n = diff(r_n);
        start_points = find(max(diff_r_n)*0.9<=diff_r_n);
        if 3 < length(start_points)
            step_size = min(diff(start_points));
            u_k = zeros(length(start_points)-2, step_size);
            for i = 2:length(start_points)-1
                u_k(i-1, :) = u_n(start_points(i):start_points(i)+step_size-1);
            end
            median_error = median(u_k(1:end-1,:))-u_k(end,:);
            standard_difference = sqrt(mean(mean(median_error.^2)));
            disp([...
                'update_message_ratio = ', num2str(round(100*update_message_ratio)), '%; ', ...
                'median_input_difference = ', num2str(standard_difference)]);
        end
        
        
        n_plot_updates = n_writing;
        n_plot_writing_last = n_writing;
    end
    
    %% Plotting
    if n == 1
        %%
        disp('Initializing plot..');
        figure_h = figure(1);
        clf;
                        
        h_plot_1_1 = subplot(2,1,1);
        h_plot = plot(nan, nan, nan, nan);
        h_plot_y = h_plot(1);
        h_plot_r = h_plot(2);
        h_plot_title = title('Initializing..');
        legend('Y', 'R');
        xlim([-inf, inf]);
        grid on;
        
        h_plot_2_1 = subplot(2,1,2);
        h_plot_u = plot(nan, nan);
        legend('U');
        xlim([-inf, inf]);
        grid on;
        
        stop_button_handle = uicontrol(figure_h, ...
            'Position',[5 5 150 30],'String','Stop',...
            'Callback', @stop_callback);
        disp('Done setting up');        
        
        %%
        
    elseif mod(n, ceil(send_frequency*window_in_seconds)) == ceil(send_frequency*window_in_seconds/2)
        disp('Plotting..');
        subplot(2,1,1);
        
        n_writing_to = n_writing; 
        n_writing_from = max([n_writing_to - send_frequency*window_in_seconds, 1]);
        sigs = BT_motor_controller.get_low_frequency_signals(n_writing_from:n_writing_to);
                
        t_n = sigs(:, 2);
        r_n = calculate_reference(t_n, reference_frequency);
        u_n = sigs(:, 3);
        y_n = sigs(:, 4);
        
        h_plot_y.XData = t_n;
        h_plot_y.YData = y_n;
        h_plot_r.XData = t_n;
        h_plot_r.YData = r_n;
        h_plot_u.XData = t_n;
        h_plot_u.YData = u_n;
        h_plot_title.String = ['Messages arrived: ', num2str(arrayfun(@(x) x.signal_n, BT_devices))];
        drawnow;
    end
    
    pause(1e-6); % Required to execute gui callback events.
end

disp('Session Closed!');

function stop_callback(~, ~)
    global run_state
    run_state = false;
end


function bluetooth_device = connect_to_device(bluetooth_name, type_number, description)
    bluetooth_device = [];
    name = ['''', description, ' (', bluetooth_name, ')'''];
    if ~isempty(bluetooth_name)
        disp(['Connecting to ' name '..']);
        bluetooth_device = SppBluetooth(bluetooth_name);
        if isempty(bluetooth_device.query('ping'))
           error(['Could not connect to ' name '!']'); 
        end
        board_type_msg = bluetooth_device.query('get_board_type');
        if board_type_msg.numbers ~= type_number
            disp('Changing board type..');
            board_type_change_msg = bluetooth_device.query('set_board_type', type_number);
            if board_type_change_msg.numbers ~= true
                error(['Could not change board type!']');
            end
        end
    else
        disp(['Skipping connection to ' name '..']);
    end
end

function r_n = calculate_reference(t, window_in_seconds)
    r_n = 10 * sin(pi/2 + 2 * pi * (2/window_in_seconds) * t);
    r_n(r_n<0) = -5;
end
