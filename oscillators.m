T = 1;
sr = 10;
dt = 1 / sr;
N = sr * T;
t = linspace(0, T, N);

function d = calculate_osc_coeff(f)
  d = (2*pi*f)^2;
endfunction

function [x, u] = osc(dt, N, d, v0, s0, h)
  v = v0;
  s = s0;
  s_1 = 0;
  for i = 1:N
    a = -d * s;

    v = v + a*dt;
    s = s + v*dt;

    s = h*s + (1-h)*s_1;
    s_1 = s;

    x(i) = s;
    u(i) = v;
  endfor
endfunction

d1 = calculate_osc_coeff(1)
d2 = calculate_osc_coeff(2)
[x1, u1] = osc(dt, N, d1, 2, 0, 1);
[x2, u2] = osc(dt, N, d2, 2, 0, 1);


#close all;
figure(1);
hold on;
plot(t, x1);
plot(t, x2);

figure(2);
hold on;
plot(t, u1);
plot(t, u2);
