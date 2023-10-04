T = 2;
sr = 1000;
dt = 1 / sr;
N = sr * T;
t = linspace(0, T, N);

function [x, u, p1] = osc(dt, N, v0, Amp, f)
  v = v0;
  s = 0;
  amp_max = Amp(1);
  d = calculate_spring_osc_coeff(f(1));
  for i = 1:N
    x(i) = s;
    u(i) = v;
    p1(i) = s;
    d_1 = d;
    d = calculate_spring_osc_coeff(f(i));
    if d_1 != 0
       delta_d = d/d_1;
      v *= sqrt(delta_d);
    endif
    a = -d * s;
    v = v + a*dt;
    s = s + v*dt;



    p1(i) = a;
  endfor
endfunction

f1 = envelope(N,
[    1 ,           2,           4,           5,           4,          5,           4],
[ 0 0 ;        0 1;       1 1;     1 0.3; 0.3 0.3;       1 1;  0.2 0.2]);

close all;

[x1, u1, p1] = osc(dt, N, 2, a1, f1 .* 70);

figure(1);
hold on;
plot(t, x1);
plot(t, f1);

