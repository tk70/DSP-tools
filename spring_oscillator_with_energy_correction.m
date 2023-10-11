clear all;

T = 1;

function [t, x, u, a_e, f_e, p, q] = osc(T, sr, v0, a_env, a, f_env, f, func)
  N = sr * T;
  dt = 1/sr;
  v = v0;
  s = 0;
  Amp = envelope(N, a_env.sizes, a_env.bounds .* a);
  f   = envelope(N, f_env.sizes, f_env.bounds .* f);
  f_1 = f(1);
  control_1 = 0;
  for i = 1:N
    x(i) = s;
    u(i) = v;

    k = calculate_spring_osc_coeff(f(i));
    if f_1 != 0
       delta_f = f(i)/f_1;
       v *= delta_f;
    endif

    E = k*s*s + v*v;
    Eset = k*Amp(i)^2;
    Emax = k; # k xmax^2, xmax = 1
    e = (Eset - E)/Emax;
    control = e;

    Z = 0.99;
    control = max(-Z, control);
    control = min(Z, control);

    a = -k * s;
    v = v + a*dt;
    s = s + v*dt;

    vmax = 2*pi*f(i);
    P = 1000;
    r = vmax * control * sign(v) * P;
    v = v + r * dt;

    f_1 = f(i);
    control_1 = control;
    p(i) = r;
    q(i) = control*6000;
  endfor

  t = linspace(0, T, N);
  a_e = Amp;
  f_e = f;
endfunction

f_env.sizes = ...
  [    1,   1];
f_env.bounds = ...
  [  0 1; 0 0];

a_env.sizes = ...
  [   1,   1,   1,   2,   0];
a_env.bounds = ...
  [ 1 1; 0 0; 1 1; 0 2; 0 0];

c8 = 4186.01;

func1 = @(control, control_1, dt) 0;
func2 = @(control, control_1, dt) 0;
[t1, x1, u1, a_e1, f_e1, p1, q1] = osc(T, 44000, 0.01, a_env, 1, f_env, c8, func1);
[t2, x2, u2, a_e2, f_e2, p2, q2] = osc(T, 96000, 0.01, a_env, 1, f_env, c8, func2);

close all;

figure(1);
subplot(4, 1, 1);
  hold on;
  plot(t1, x1);
  plot(t1, a_e1);

subplot(4, 1, 2);
  hold on;
  plot(t1, p1);
  plot(t1, q1);

subplot(4, 1, 3);
  hold on;
  plot(t2, x2);
  plot(t2, a_e2);

subplot(4, 1, 4);
  hold on;
  plot(t2, p2);
  plot(t2, q2);
