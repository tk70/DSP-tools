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

function spec = generate_spectrogram(signal_in_freq_domain)
  for i = 1:size(signal_in_freq_domain)(2)
    block = signal_in_freq_domain(:, i);
    N = length(block);
    spec(i, 1:N/2) = abs(block(1:N/2));
  endfor
endfunction

function [x, y] = calculate_spectrogram_ranges(info, spec)
  N = size(spec)(2);
  x = linspace(0, info.TotalSamples/info.SampleRate, size(spec)(1));
  y = linspace(0, info.SampleRate/2, N/2);
endfunction

file = "sample5.wav";
info = audioinfo(file);
[y, fs] = audioread(file);

N = 2048 * 2; # window size

t0 = clock();

freq = transform_to_freq_domain(y, N, info);
spec = generate_spectrogram(freq);
result = transform_to_time_domain(freq, info);

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

[x, y] = calculate_spectrogram_ranges(info, spec);
imagesc(x, y, power(spec, 0.5)');
colorbar();
ylabel ("f");

audiowrite('out.wav', result, fs);
