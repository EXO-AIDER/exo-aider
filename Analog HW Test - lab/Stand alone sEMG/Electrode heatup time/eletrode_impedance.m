clc; clear all; close all;
%% Specify data of interests 
csv_name = 'Impedance 1.csv';
% csv_name = 'Impedance 2.csv';
% csv_name = 'Impedance 3.csv';
% csv_name = 'Impedance 4.csv';
% csv_name = 'Impedance 5.csv';
% csv_name = 'Impedance 6.csv';
% csv_name = 'Impedance 7.csv';
% csv_name = 'Impedance 8.csv';
%% Read data
data = csvread(csv_name,5,0); % [time, voltage]


%% Notch filter 
% T = diff(data(1:2,1)); % Sampling period       
% Fs = 1/T; 
% wo = 50/(Fs/2);  
% bw = wo/80;
% [b,a] = iirnotch(wo,bw);
% 
% for n = 1:100  % Agressive itterative filtration
%     data(:,2) = filter(b,a,data(:,2));
% end

%% FFT of Data      
% https://se.mathworks.com/help/matlab/ref/fft.html

T = diff(data(1:2,1)); % Sampling period       
Fs = 1/T;              % Sampling frequency 
L = length(data);      % Length of signal
t = (0:L-1)*T;         % Time vector

Y = fft(data(:,2));

P2 = abs(Y/L);  
P1 = P2(1:L/2+1); 
P1(2:end-1) = 2*P1(2:end-1);

f = Fs*(0:(L/2))/L;

%% Plot 
% Signal 
subplot(2,1,1)
plot(data(:,1),data(:,2))
title('Signal')
xlabel('Time [s]')
ylabel('Voltage [V]')
grid on


% FFT
subplot(2,1,2)
semilogx(f,P1) 
title('Single-Sided Amplitude Spectrum of X(t)')
xlabel('f (Hz)')
ylabel('|P1(f)|')
axis([0 1000 min(P1) max(P2)])
grid on 





