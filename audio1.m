clear;

function mask = generate_window_function(n)
  w = @(i) sin(pi/n*(i + 0.5));
  for i = 1:n
    mask(i) = w(i);
  endfor
endfunction

function result = transform_to_freq_domain(signal, N, info)
  mask = generate_window_function(N);
  M = info.TotalSamples;
  index = 1;
  windowCount = 1;
  step = N / 2;
  while index < M - N
    block = signal(index:index+N-1);
    blockMasked = block .* mask';
    Y = fft(blockMasked);
    result(:, windowCount) = Y;
    index = index + step;
    windowCount = windowCount + 1;
  endwhile
endfunction

function result = transform_to_time_domain(signal, info)
  N = size(signal)(1);
  M = info.TotalSamples;
  windowCount = size(signal)(2);
  mask = generate_window_function(N);
  result = zeros(1, M);
  index = 1;
  step = N / 2;
  for i = 1:windowCount
    Y = signal(:, i);
    block = ifft(Y);
    blockMasked = block' .* mask;
    result(index:index+N-1) = result(index:index+N-1) + blockMasked;
    index = index + step;
  endfor
endfunction

function [spec, x_range, y_range] = generate_spectrogram(signal_in_freq_domain, info, part)
  N = size(signal_in_freq_domain)(1);
  k = round(N/2 * part);
  for i = 1:size(signal_in_freq_domain)(2)
    block = signal_in_freq_domain(:, i);
    spec(i, 1:k) = abs(block(1:k));
  endfor
  x_range = linspace(0, info.TotalSamples/info.SampleRate, size(spec)(1));
  y_range = linspace(0, info.SampleRate/2, N/2 * part);
endfunction

function signal_in_freq_domain = apply_tranformation(t0, t1, f, signal_in_freq_domain, info)
  N = size(signal_in_freq_domain)(1);
  windowCount = size(signal_in_freq_domain)(2);
  i0 = max(1, round(t0 * info.SampleRate / N * 2));
  i1 = min(round(t1 * info.SampleRate / N * 2), windowCount);
  for i = i0:i1
    signal_in_freq_domain(:, i) = f(signal_in_freq_domain(:, i));
  endfor
endfunction

function Y = g1(y)
  t = 1:1:length(y);
  d = 1 * sin(t / length(y) * 2 * pi * 5.5);
  ti = t + d;
  Y = interp1(t, y, ti, "pchip");
endfunction

# frequency in Hz to freq in frequency domain
function k = f_to_k(f, N, info)
  k = round(f / info.SampleRate * N);
  k = min(N, max(1, k));
endfunction

function Y = move_freq(y, f_src, f_dst, info)
  N = length(y);
  k0 = f_to_k(f_src, N, info);
  k1 = f_to_k(f_dst, N, info);

  x = 1:1:N;
  xi = x;
  xi(k1) = k0;
  xi(k1-4:k1) = linspace(xi(k1-4), xi(k1), 5);
  xi(k1:k1+4) = linspace(xi(k1), xi(k1+4), 5);
  delta = xi(1:N/2) - x(1:N/2);
  delta = flip(delta);
  xi(N/2+1:end) = xi(N/2+1:end) + delta;
  Y = interp1(x, y, xi, "pchip");
endfunction

file = "sample5.wav";
info = audioinfo(file);
[y, fs] = audioread(file);

N = 2048 * 2; # window size

t0 = clock();

freq = transform_to_freq_domain(y, N, info);
g = @(y) move_freq(y, 524, 553, info);
freq2 = apply_tranformation(2.5, 3.5, g, freq, info);

g = @(y) move_freq(y, 1050, 1180, info);
freq2 = apply_tranformation(2.5, 3.5, g, freq2, info);

result = transform_to_time_domain(freq2, info);

etime(clock(), t0)

M = length(result);
diff = abs(result - y(1:M)');
sum(diff)

t = linspace(0, 1, M);

figure(1);

#subplot(1, 3, 1, 'input');
plot(t, y(1:M));

#subplot(1, 3, 2, 'output');
plot(t, result);

figure(2);
#subplot(1, 3, 3, 'spec;');

part = 1;

[spec, x, y] = generate_spectrogram(freq, info, part);
imagesc(x, y, power(spec, 0.5)');
%colorbar();
ylabel ("f[Hz]");
xlabel ("t[s]");

figure(3);
[spec, x, y] = generate_spectrogram(freq2, info, part);
imagesc(x, y, power(spec, 0.5)');
%colorbar();
ylabel ("f[Hz]");
xlabel ("t[s]");

audiowrite('out.wav', result, fs);
