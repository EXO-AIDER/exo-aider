clear, close all, clc;

%%% High pass %%%
HP = readtable('HP_swept_sine_10_1k_1V', 'HeaderLines', 8);

figure();
subplot(2,1,1)
semilogx(HP.Freq, HP.Amplitude);
title('20 Hz high pass filter, 10-1 kHz, @1 V')
xlabel('Frequency [Hz]')
ylabel('Magnitude [dB]')
ylim([-81 50])
grid

subplot(2,1,2)
semilogx(HP.Freq, HP.Phase);
xlabel('Frquency [Hz]')
ylabel('Phase [deg]')
grid


%% Low pass %%%
LP = readtable('LP_swept_sine_10_1k_1V', 'HeaderLines', 8);

figure();
subplot(2,1,1)
semilogx(LP.Freq, LP.Amplitude);
title('500 Hz low pass filter, 10-1 kHz, @1 V')
xlabel('Frequency [Hz]')
ylabel('Magnitude [dB]')
ylim([-81 50])
grid

subplot(2,1,2)
semilogx(LP.Freq, LP.Phase);
xlabel('Frquency [Hz]')
ylabel('Phase [deg]')
grid


%% Notch %%%
notch = readtable('Notch_swept_sine_10_1k_1V', 'HeaderLines', 8);

figure();
subplot(2,1,1)
semilogx(notch.Freq, notch.Amplitude);
title('50 Hz Notch filter, 10-1 kHz, @1 V')
xlabel('Frequency [Hz]')
ylabel('Magnitude [dB]')
ylim([-81 50])
grid

subplot(2,1,2)
semilogx(notch.Freq, notch.Phase);
xlabel('Frquency [Hz]')
ylabel('Phase [deg]')
grid



%% Diff amp %%%
diff = readtable('DIFF_swept_sine_10_1k_100mV', 'HeaderLines', 8);

figure();
subplot(2,1,1)
semilogx(diff.Freq, diff.Amplitude);
title('Differential amplifier, 10-1 kHz, @100 mV')
xlabel('Frequency [Hz]')
ylabel('Magnitude [dB]')
ylim([-81 50])
grid

subplot(2,1,2)
semilogx(diff.Freq, diff.Phase);
xlabel('Frquency [Hz]')
ylabel('Phase [deg]')
grid

%% All NOT MEASURED, JUST SUMMED%%%
figure();
subplot(2,1,1)
semilogx(notch.Freq, notch.Amplitude+LP.Amplitude+HP.Amplitude+diff.Amplitude);
title('Sum of all filters, 10-1 kHz, @1 V')
xlabel('Frequency [Hz]')
ylabel('Magnitude [dB]')
ylim([-81 50])
grid

subplot(2,1,2)
semilogx(notch.Freq, notch.Phase+LP.Phase+HP.Phase+diff.Phase);
xlabel('Frquency [Hz]')
ylabel('Phase [deg]')
grid
%% Full system %%%
full = readtable('Full_system_swept_sine_10_1k_1V', 'HeaderLines', 8);

figure();
subplot(2,1,1)
semilogx(full.Freq, full.Amplitude);
title('Full system, 10-1 kHz, @1 V')
xlabel('Frequency [Hz]')
ylabel('Magnitude [dB]')
ylim([-81 50])
grid

subplot(2,1,2)
semilogx(full.Freq, full.Phase);
xlabel('Frquency [Hz]')
ylabel('Phase [deg]')
grid