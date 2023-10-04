T = 2;
sr =2000;
dt = 1 / sr;
N = sr * T;
t = linspace(0, T, N);

function [x, u, p1, p2] = osc(dt, N, v0, Amp, f)
  v = v0;
  s = 0;
  f_1 = f(1);
  for i = 1:N
    x(i) = s;
    u(i) = v;
    p1(i) = s;

    k = calculate_spring_osc_coeff(f(i));
    if f_1 != 0
       delta_f = f(i)/f_1;
       v *= delta_f;
    endif

     E = k*s*s + v*v;
     Eset = Amp(i)^2*k;
     control = Eset - E;
     control = max(-0.05, control)*dt;
     control = min(0.05, control)*dt;

     v = v* (1+control);

##    p1(i) = k*s*s;
##    p2(i) = v*v;
    p1(i) = E;
    p2(i) = 1+control;

    a = -k * s;
    v = v + a*dt;
    s = s + v*dt;



    f_1 = f(i);

  endfor
endfunction

f1 = envelope(N,
[    1 ,           2,           4,           5,           4,          5,           4],
[ 0 0 ;        0 1;       1 1;     1 0.3; 0.3 0.3;       1 1;  0.2 0.2]);

f1 = envelope(N,
[    1],
[ 1 1]);

a1 = envelope(N,
[    1],
[ 1 1]);

close all;

[x1, u1, p1, p2] = osc(dt, N, 1, a1, f1 .* 10);

figure(1);
hold on;
plot(t, x1);
#plot(t, f1);
plot(t, p1);
plot(t, p2);
