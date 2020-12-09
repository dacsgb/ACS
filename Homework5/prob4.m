clc

% Lead
alpha = 0.02;
T1 = 1;
Lead = tf([alpha*T1, 1],[T1, 1])/alpha;

% Lag
beta = 1;
T2 = 0.5;
Lag = tf([T2, 1],[beta*T2, 1]);

% Pendulum
P = tf([0.5],[1,0.1,-5]);

sys = P*Cont
stepinfo(sys)
isstable(sys)
figure(1)
bode(sys)
figure(2)
pzplot(sys)