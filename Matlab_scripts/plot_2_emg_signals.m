clc, close all, clear;
data = readtable('DataTable');

plot(data.Time, data.EMG1);
hold on;
plot(data.Time, data.EMG2);
hold off;

Fs = 1000;            % Sampling frequency                    
T = 1/Fs;             % Sampling period       
L = length(data.EMG1);% Length of signal
t = (0:L-1)*T;        % Time vector

fourier1 = fft(data.EMG1);
fourier2 = fft(data.EMG2);

P21 = abs(fourier1/L);
P11 = P21(1:L/2+1);
P11(2:end-1) = 2*P11(2:end-1);

P22 = abs(fourier2/L);
P12 = P22(1:L/2+1);
P12(2:end-1) = 2*P12(2:end-1);

f = Fs*(0:(L/2))/L;

figure()
plot(f,P11)
hold on
plot(f,P12)

title('Single-Sided Amplitude Spectrum of X(t)')
xlabel('f (Hz)')
ylabel('|P1(f)|')