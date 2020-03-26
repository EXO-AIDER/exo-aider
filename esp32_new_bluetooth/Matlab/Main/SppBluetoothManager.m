classdef SppBluetoothManager < handle
    %SPPBLUETOOTHMANAGER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        devices SppBluetooth
    end
    
    
    methods
        function obj = SppBluetoothManager()
        end
        
        function add_device(obj, device)
            obj.devices(end+1) = device;
        end
        
        function set_sample_frequency(obj, sample_frequency)
           for device = obj.devices
              device.sample_frequency = sample_frequency;
           end
        end
        function set_send_signals_ratio(obj, send_signals_ratio)
           for device = obj.devices
              device.send_signals_ratio = send_signals_ratio;
           end
        end
        function set_send_signals(obj, send_signals)
           for device = obj.devices
              device.send_signals = send_signals;
           end
        end
        
        % ---
             
        function playout_buffer_size = estimate_playout_buffer_size(obj, num_times)
            if nargin < 2
                num_times = 20;
            end
            obj.send_signals = false;
            obj.flush;
            obj.send_signals = true;
            
            latancy_array = [];
            for device = obj.devices
                device.send_signals = false;
                [mean_latancy, std_latancy, ~] = device.estimate_latancy(num_times);
                latancy_array(end+1) = mean_latancy + std_latancy * 3;
                device.send_signals = true;
            end
            
            obj.send_signals = false;
            max_latancy_time = max(latancy_array);
            playout_buffer_size = ceil(obj.send_frequency * max_latancy_time);
        end
    end
    
    methods (Static)
        function list_availiable_bluetooth_devices()
            disp('Determining availiable bluetooth devices. Please wait..');
            devices =  instrhwinfo('Bluetooth');
            disp('Availiable bluetooth devices:');
            for i = 1:length(devices.RemoteNames)
               disp([' * ',  devices.RemoteNames{i}]);
            end
        end
    end
    
    properties
        sample_frequency       
        send_signals_ratio
        send_signals 
    end
    methods
        function set.sample_frequency(obj, val)
           for device = obj.devices
              device.sample_frequency = val;
           end
        end
        function val = get.sample_frequency(obj)
            val = unique(arrayfun(@(x) x.sample_frequency, obj.devices));
        end
        
        function set.send_signals_ratio(obj, val)
           for device = obj.devices
              device.send_signals_ratio = val;
           end
        end
        function val = get.send_signals_ratio(obj)
            val = unique(arrayfun(@(x) x.send_signals_ratio, obj.devices));
        end
        
        function set.send_signals(obj, val)
           for device = obj.devices
              device.send_signals = val;
           end
        end
        function val = get.send_signals(obj)
            val = unique(arrayfun(@(x) x.send_signals, obj.devices));
        end
        
        function flush(obj)
           for device = obj.devices
              device.flush;
           end
        end
        function val = signal_n(obj)
           val = unique(arrayfun(@(x) x.signal_n, obj.devices));
        end
        
        function val = send_frequency(obj)
           val = obj.sample_frequency / obj.send_signals_ratio;
        end
    end
end

