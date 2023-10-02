fs = 44000;
t1 = 3;
t = linspace(0, t1, fs*t1);
d = 10000;

A0 = 220;
Bb0 = A0 * 2^(1/12);
B0 =  A0 * 2^(2/12);
C1 =  A0 * 2^(3/12);
Db1 = A0 * 2^(4/12);
D1 =  A0 * 2^(5/12);
Eb1 = A0 * 2^(6/12);
E1 =  A0 * 2^(7/12);
F1 =  A0 * 2^(8/12);
Gb1 = A0 * 2^(9/12);
G1 =  A0 * 2^(10/12);
Ab1 = A0 * 2^(11/12);
A1 =  A0 * 2;
Bb1 = Bb0 * 2;
B1 =  B0 * 2;
C2 =  C1 * 2;

function y = tone(t, h, amp)
  y = sum(sin(h*t.*2*pi) .* amp);
end;

function h = harm(amp)
  h = (1:1:size(amp)(1))';
end;

function h = harmx(amp)
  h = (harm(amp) * 2) .^ 0.999 / 2;
end;

function h = chord(pattern, notes)
end;



s = [1 0]';
s1 = [0.5, 0.1, 0.1, 0.2, 0.0, 0.1, 0.0, 0.2, 0.0]';

y = tone(t, harm(s1)*C1, s1);

figure(1)
plot(y(1:fs/base))

audiowrite('out.wav', real(y), fs);
