clear;

file = "sample7.wav";
info = audioinfo(file);
[y, fs] = audioread(file);

#M = 22500; # num samples taken from file
M = info.TotalSamples;

N = 4096 * 2; # window size
step = N / 2;

w = @(n) sin(pi/N*(n + 0.5));
f = @(y) y;

t0 = clock();

for i = 1:N
  mask(i) = w(i);
endfor

result = zeros(1, M);

index = 1;
windowCount = 1;
while index < M - N
  segment = y(index:index+N-1);
  segmentMasked = segment .* mask';
  plot(segmentMasked)
  Y = fft(segmentMasked);
  Y2 = f(Y);
  spec(windowCount, 1:N/2) = abs(Y(1:N/2));
  YY = ifft(Y2);
  YYMasked = YY' .* mask;
  result(index:index+N-1) = result(index:index+N-1) + YYMasked;
  index = index + step;
  windowCount = windowCount + 1;
endwhile

diff = abs(result - y(1:M)');
sum(diff)

etime(clock(), t0)

t = linspace(0, 1, M);

figure(1);

#subplot(1, 3, 1, 'input');
plot(t, y(1:M));

#subplot(1, 3, 2, 'output');
plot(t, result);

figure(2);
#subplot(1, 3, 3, 'spec;');
imagesc(power(spec, 0.5)');
colorbar();

audiowrite('out.wav', result, fs);
