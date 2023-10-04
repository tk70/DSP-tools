T = 2;
sr = 1000;
dt = 1 / sr;
N = sr * T;
t = linspace(0, T, N);

function [x, u, amp, p1, p2] = osc(dt, N, v0, Amp, f)
  v = v0;
  s = 0;
  amp_max = Amp(1);

  for i = 1:N
    v_1 = v;
    s_1 = s;
    u(i) = v;
    x(i) = s;

    d = calculate_spring_osc_coeff(f(i));
    a = -d * s;
    v = v + a*dt;
    s = s + v*dt;

##    s *= (1 - 5*dt);
##    v *= (1 - 1*dt);

    lim = min(1.0, Amp(i) * 1.1) ;
    throt = dt * 100;
    if s > lim
      s -= (s - lim) * (s - lim) * throt;
    endif

    if s  <  -lim
      s += (-s - lim) * (-s - lim) * throt;
    endif

    if (sign(v) != sign(v_1))
      amp_max = abs(s);
    endif
    amp_max = max(amp_max, abs(s));
    amp(i) = amp_max;

    e = Amp(i) - amp_max;
    p1(i) = amp_max;
    p2(i) = e;

    m = 1 + max(min(e, 0.3), -0.3) * dt * 100;
    v *= m;

    v_1 = v;
    s_1 = s;
  endfor
endfunction

f1 = envelope(N,
[    1 ,           2,           4,           5,           4,          5,           4],
[ 0 0 ;        0 1;       1 1;     1 0.3; 0.3 0.3;       1 1;  0.2 0.2]);

##f1 = envelope(N,
##[         1,           4,           10],
##[    .0 .0;        0 1;      .1 .2 ]);

a1 = envelope(N,
[    1 ,           2,           4,           2,           4,          5,           2],
[ 0 0 ;        0 1;       1 1;  0.5 0.5; 0.5 0.1;     0.1 1;     1 1]);

##a1 = envelope(N,
##[       0 ,           0,           0,           0,            1],
##[ .0 .0 ;       .7 .7;       1 1;       .5 .5;      .8 .8]);

close all;

figure(1);
plot(a1);

[x1, u1, amp1, p1, p2] = osc(dt, N, 2, a1, f1 .* 70);

figure(2);
hold on;
plot(t, x1);
plot(t, a1);
plot(t, p1);
plot(t, p2);

##figure(3);
##plot(t, u1);

