clear, close all, clc

%%% Generate filter %%%
fs = 1000;
fL = 49;
fH = 51;

[b_cheb,a_cheb] = cheby1(3,40,[fL*2/fs fH*2/fs],'stop');
[f_cheb, h_cheb] = freqz(b_cheb, a_cheb, fs);
[amp_cheb, time] = impz(b_cheb, a_cheb);

[b_cheb_inv,a_cheb_inv] = cheby2(3,40,[fL*2/fs fH*2/fs],'stop');
[f_cheb_inv, h_cheb_inv] = freqz(b_cheb_inv, a_cheb_inv, fs);

[b_but,a_but] = butter(3,[fL*2/fs fH*2/fs],'stop');
[f_but, h_but] = freqz(b_but, a_but, fs);

%%% Test signal %%%
t = linspace(0,1, fs);
sig = sin(2*pi*50*t);

x = fs*h_cheb_inv/(2*pi);

%%% Filter signal %%% Not working atm!
filt_cheb =     conv(ifft(f_cheb), x, 'same');
filt_cheb_inv = conv(ifft(f_cheb_inv), x, 'same');
filt_but =      conv(ifft(f_but), x, 'same');


%%% plotting %%%
figure()
plot(time, )

figure()
plot(t, sig)

figure()
plot(t(1: length(filt_cheb_inv)), filt_cheb_inv, t(1: length(filt_but)), filt_but, t(1: length(filt_cheb)), filt_cheb)
legend('Inverse chebyshev', 'Butterworth', 'chebyshev')

figure();
plot(x, 20*log10(abs(f_cheb_inv)), x, 20*log10(abs(f_but)), x, 20*log10(abs(f_cheb)));
legend('Inverse chebyshev', 'Butterworth', 'chebyshev')