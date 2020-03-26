clear all

sample_frequency = 1000;
downsampled_frequency = 500;

samples = 2000;


[p, q] = rat(sample_frequency/downsampled_frequency, 1e-2);

actual_downsampled_frequency = 0;


t_n = (0:samples-1)/sample_frequency;
t_downsampled_n = (0:samples-1)/downsampled_frequency;
t_downsampled_n(max(t_n) < t_downsampled_n) = [];

N = floor(sample_frequency/2);
f_N = 1:N;

reconstruction = zeros(1, N)*nan;
for f_n = 1:N    
    original_signal = sin(2 * pi * t_n * f_n);
    downsampled_signal = sin(2 * pi * t_downsampled_n * f_n);
    
    resampled_signal = resample(downsampled_signal, p, q);
    
    N_min = min([length(resampled_signal), length(original_signal)]);
    
    reconstruction(f_n) = mean(mean((original_signal(1:N_min)-resampled_signal(1:N_min)).^2));
end


plot(reconstruction);


