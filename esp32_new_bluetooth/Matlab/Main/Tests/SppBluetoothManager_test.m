clear all; clc;

disp('Connecting to devices..');
motor_controller = SppBluetooth('F4418CA4AE30@Exo-Aider', 'demo_motor_controller', 60 * 1000);
left_sensor_band = []; %SppBluetooth('60FB9912CFA4@Exo-Aider', 'demo_left_sensor_band', 60 * 1000);
right_sensor_band = []; %SppBluetooth('74E80B12CFA4@Exo-Aider', 'demo_right_sensor_band', 60 * 1000);

devices = [motor_controller, left_sensor_band, right_sensor_band];

%
disp('Configuring SppBluetoothManager..');
BT = SppBluetoothManager;
for device = devices  
    BT.add_device(device);
end

%
disp('Starting simple tests..');

for device_ = {devices, BT}
    for device = device_{1}
        is_spp = isa(device, 'SppBluetooth');
        if is_spp
            name = [device.name, ' (' device.description ')'];
        else
            name = 'SppManager';
        end
        
        device.sample_frequency = 1000;
        assert(device.sample_frequency == 1000);
        device.sample_frequency = 500;
        assert(device.sample_frequency == 500);

        device.send_signals_ratio = 10;
        assert(device.send_signals_ratio == 10);
        device.send_signals_ratio = 5;
        assert(device.send_signals_ratio == 5);

        device.sample_frequency = 1000;
        device.send_signals_ratio = 10;
        device.send_signals = true;
        assert(device.send_signals == true);
        device.flush;
        pause(1);
        signals_got = min(device.signal_n);
        assert(50 <= signals_got);
        device.send_signals = false;
        assert(device.send_signals == false);

        disp([' * ', name, ' - pass!']);
    end
end

disp('All simple tests passed!');


BT.sample_frequency = 1000;
BT.send_signals_ratio = 10;
BT.estimate_playout_buffer_size

%% Make a simulation
time_to_run = 20;
sample_frequency = 1000;
send_signals_ratio = 20;
reference_frequency = 4/time_to_run;

% Initial values
n = 0;
sim_start_time = tic;
t_last = 0;
u_integrator = 0;

% Initialize
BT.send_signals = false;
BT.sample_frequency = sample_frequency;
BT.send_signals_ratio = send_signals_ratio;
send_frequency = BT.send_frequency;
BT.flush;
BT.send_signals = true;


while toc(sim_start_time) < time_to_run
    n = n + 1;
    
    % Take care of sheduling
    t_now = toc(sim_start_time);
    t_next = t_last + 1 / send_frequency;
    t_wait = t_next - t_now;
    if 0 < t_wait
        pause(t_wait);
        t_last = t_next;
    else
        t_last = toc(sim_start_time); 
        disp(['Can''t keep up! ', num2str(-t_wait* 1e3) , ' ms behind.']);
    end

    % Calculate reference:
    y_n = motor_controller.get_signals('y', -1);
    u_n = motor_controller.get_signals('u', -1);
    t_n = t_now; %motor_controller.get_signals('t', -1);
    r_local = calculate_reference(t_n, reference_frequency);

    e = r_local - y_n;
    u_integrator = u_integrator + e / send_frequency;
    u_input = e * 1 + u_integrator * 10;
    
    u_input = min([max([u_input, -100]), 100]); % Input saturation
    motor_controller.send('u', [u_input, r_local]);
    
    
    disp([t_n, u_input, u_n, y_n, r_local]);
end
motor_controller.send('u', 0);
BT.send_signals = false;
disp('done');

t_n = motor_controller.get_signals('t');
y_n = motor_controller.get_signals('y');
r_n = motor_controller.get_signals('r');
u_n = motor_controller.get_signals('u');

figure(1);
subplot(2,1,1);
plot(t_n, y_n, t_n, r_n);
legend('y', 'r');

subplot(2,1,2);
plot(t_n, u_n);
legend('u');

function r_n = calculate_reference(t, frequency)
    r_n = 10 * sin(pi/2 + 2 * pi * frequency * t);
    r_n(r_n<0) = -5;
end





