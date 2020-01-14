clear, close all, clc;
HP = readtable('HP_swept_sine_10_1k_1V', 'HeaderLines', 8);

figure();
subplot(2,1,1)
semilogx(HP.Freq, HP.Amplitude);
title('20 Hz high pass filter, 10-1 kHz, @1 V')
xlabel('Frequency [Hz]')
ylabel('Magnitude [dB]')
grid

subplot(2,1,2)
semilogx(HP.Freq, HP.Phase);
xlabel('Frquency [Hz]')
ylabel('Phase [deg]')
grid

figure()
semilogx(HP.Freq, HP.THD)
grid