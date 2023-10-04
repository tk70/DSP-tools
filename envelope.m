function x = envelope(N, sizes, ranges)
  S = sum(sizes);
  x = [];
  M = length(sizes);
  for i = 1:M-1
    n = round(N * sizes(i) / S);
    x = [x linspace(ranges(i,1), ranges(i,2), n)];
  endfor
  x = [x linspace(ranges(M,1), ranges(M,2), N - length(x))];
endfunction
