clear, close all, clc;

%%% High pass %%%
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


%%% Low pass %%%
LP = readtable('LP_swept_sine_10_1k_1V', 'HeaderLines', 8);

figure();
subplot(2,1,1)
semilogx(LP.Freq, LP.Amplitude);
title('500 Hz low pass filter, 10-1 kHz, @1 V')
xlabel('Frequency [Hz]')
ylabel('Magnitude [dB]')
grid

subplot(2,1,2)
semilogx(LP.Freq, LP.Phase);
xlabel('Frquency [Hz]')
ylabel('Phase [deg]')
grid


%%% Notch %%%
notch = readtable('Notch_swept_sine_10_1k_1V', 'HeaderLines', 8);

figure();
subplot(2,1,1)
semilogx(notch.Freq, notch.Amplitude);
title('50 Hz Notch filter, 10-1 kHz, @1 V')
xlabel('Frequency [Hz]')
ylabel('Magnitude [dB]')
grid

subplot(2,1,2)
semilogx(notch.Freq, notch.Phase);
xlabel('Frquency [Hz]')
ylabel('Phase [deg]')
grid

%%% All %%%
figure();
subplot(2,1,1)
semilogx(notch.Freq, notch.Amplitude+LP.Amplitude+HP.Amplitude);
title('Sum of all filters, 10-1 kHz, @1 V')
xlabel('Frequency [Hz]')
ylabel('Magnitude [dB]')
grid

subplot(2,1,2)
semilogx(notch.Freq, notch.Phase);
xlabel('Frquency [Hz]')
ylabel('Phase [deg]')
grid