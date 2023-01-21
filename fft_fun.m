N = 32;
t = linspace(0, 2*pi, N)';

y = sin(t*1.5) ;
#y = sin(t) + sin(3*t);
#y = sin(t) + sin(4*t) + sin(8*t) + sin(16*t)

s = fft(y);


mask = zeros(N, 1);
mask(1:5) = 1;
#fs = 16;
#f = (0:N-1)*(fs/N)
#power = abs(s).^2/N

#s = s .* mask;

figure(1);
hold on;
plot(linspace(0, 1, N), y);
plot(linspace(0, 1, N), ifft(s));
hold off;

figure(2);
subplot (2, 1, 1)
stem(linspace(0, N, N), real(s));
subplot (2, 1, 2)
stem(linspace(0, N, N), imag(s));
hold off

##figure(3);
##plot(f, power);
