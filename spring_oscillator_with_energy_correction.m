clear all;

T = 4;

function [t, x, u, a_e, f_e, p1, p2] = osc(T, sr, v0, a_env, a, f_env, f, func)
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
    p1(i) = s;

    k = calculate_spring_osc_coeff(f(i));
    if f_1 != 0
       delta_f = f(i)/f_1;
       v *= delta_f;
    endif

    E = k*s*s + v*v;
    Amp2 = Amp(i)^2;
    Eset = Amp2*k;
    control = Eset - E;
    Z = 0.9;
    control = max(-Z, control);
    control = min(Z, control);
    control = func(control, control_1, dt);

    v = v* (1+control);
    s = s* (1+control);

    p1(i) = E;
    p2(i) = control * 10;

    a = -k * s;
    v = v + a*dt;
    s = s + v*dt;

    f_1 = f(i);

    control_1 = control;
  endfor

  t = linspace(0, T, N);
  a_e = Amp;
  f_e = f;
endfunction

f_env.sizes = ...
  [    1]
f_env.bounds = ...
  [  0 1];

a_env.sizes = ...
  [   1,   1,   1,   2,   0];
a_env.bounds = ...
  [ 1 1; 0 0; 1 1; 0 2; 0 0];

func1 = @(control, control_1, dt) (control + 0*control_1)/1 * 30 * dt;
func2 = @(control, control_1, dt) (control + 1*control_1)/2 * 30 * dt;
[t1, x1, u1, a_e1, f_e1, p1, q1] = osc(T, 100, 1, a_env, 1, f_env, 20, func1);
[t2, x2, u2, a_e2, f_e2, p2, q2] = osc(T, 100, 1, a_env, 1, f_env, 20, func2);

close all;

figure(1);
subplot(2, 1, 1);
  hold on;
  plot(t1, x1);
  plot(t1, a_e1);

subplot(2, 1, 2);
  hold on;
  plot(t2, x2);
  plot(t2, a_e2);
