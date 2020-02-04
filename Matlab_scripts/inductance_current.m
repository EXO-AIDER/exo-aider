L=22e-6;
R=0.9;
V=12;
tau = L/R;

I = V/R*(1-exp(-(t*R)/L));

t = linspace(0,10)*tau;

plot(t, I)
