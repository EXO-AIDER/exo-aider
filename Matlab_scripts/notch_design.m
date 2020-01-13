clear, close all, clc

%%% Generate filter %%%
fs = 1000;
fL = 45;
fH = 55;

% Chebyshev
[b_cheb,a_cheb] = cheby1(3,40,[fL*2/fs fH*2/fs],'stop');
[h_cheb, f_cheb] = freqz(b_cheb, a_cheb, fs);
[h_che, t_che] = impz(b_cheb, a_cheb, 100, fs);

% Inverse Chebyshev
[b_cheb_inv,a_cheb_inv] = cheby2(3,40,[fL*2/fs fH*2/fs],'stop');
[h_cheb_inv, f_cheb_inv] = freqz(b_cheb_inv, a_cheb_inv, fs);
[h_che_inv, t_che_inv] = impz(b_cheb_inv, a_cheb_inv, 100, fs);

% Butterworth
[b_but,a_but] = butter(3,[fL*2/fs fH*2/fs],'stop');
[h_but,f_but] = freqz(b_but, a_but, fs);
[h_butt, t_butt] = impz(b_but, a_but, 100, fs);

%%% Test signal %%%
t = linspace(0,1, fs);
sig = sin(2*pi*50*t);

%%% Filter signal %%% Not working atm!
filt_cheb       = conv(sig, h_che, 'valid');
filt_cheb_inv   = conv(sig, h_che_inv, 'valid');
filt_but        = conv(sig, h_butt, 'valid');


%%% plotting %%%
% Original test signal
figure()
plot(t, sig)
title('Original signal')
xlabel('Time [s]')
ylabel('Amplitude [*]')

% Filtered test signal
figure()
plot(t(1: length(filt_cheb_inv)), filt_cheb_inv)
hold on
plot(t(1: length(filt_but)), filt_but)
plot(t(1: length(filt_cheb)), filt_cheb)
legend('Inverse chebyshev', 'Butterworth', 'chebyshev', 'Location','SouthWest')
hold off
title('Filtered signal')
xlabel('Time [s]')
ylabel('Amplitude [*]')

% Frequency response of filters
figure();
semilogx(fs*f_cheb_inv/(2*pi), mag2db(abs(h_cheb_inv)))
hold on
semilogx(fs*f_but/(2*pi), mag2db(abs(h_but)))
semilogx(fs*f_cheb/(2*pi), mag2db(abs(h_cheb)))
legend('Inverse chebyshev', 'Butterworth', 'chebyshev', 'Location','SouthWest')
grid on
hold off
% xlim([min(f_but), max(f_but)])
title('Frequency response')
xlabel('Frequency [Hz]')
ylabel('Amplitude [dB]')

%% Manual filtering with Butterworth
clear, close all, clc;

% Design filter

fs = 1000;
fL = 45;
fH = 55;

[b,a] = butter(3,[fL*2/fs fH*2/fs],'stop');
[h,f] = freqz(b, a, fs);
[h_i, t] = impz(b, a, 100, fs);

% Signal
time = linspace(0,1, 1*fs);
sig = sin(2*pi*50*time) + sin(2*pi*20*time);

y = zeros(length(time),1);

% Manual filtering
for n=7:length(time)
    y(n) = b(1)*sig(n)+b(2)*sig(n-1)+b(3)*sig(n-2)+b(4)*sig(n-3)...
        +b(5)*sig(n-4)+b(6)*sig(n-5)+b(7)*sig(n-6)-a(2)*y(n-1)-...
        a(3)*y(n-2)-a(4)*y(n-3)-a(5)*y(n-4)-a(6)*y(n-5)-a(7)*y(n-6);
end

filt = filter(h_i, 1, sig);

plot(time, sig)
hold on
plot(time(1:length(filt)), filt)
plot(time, y)
legend('Original signal','Filtered with Matlab','Manually implemented')
hold off

%% moving average test
clear, close all, clc;

fs = 1000;
t = linspace(0,1,fs);

sig = sin(2*pi*50*t) + sin(2*pi*200*t);

y = zeros(length(t),1);

for n =10:fs-9;
    y(n) = 1/9*(sig(n) + sig(n-1) + sig(n-2) + sig(n-3) + sig(n-4) ...
        + sig(n-5) + sig(n-6) + sig(n-7) + sig(n-8) + sig(n-9));
end

figure()
plot(t, sig)
hold on 
plot(t, y)