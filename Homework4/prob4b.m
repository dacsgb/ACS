% Clear Figures and terminal
clc
clf

% Print program name
Program = "Problem 4 B"

% create System TF
H_o = tf([19.2],[1,2.625,0]);

% create Controller TF
C = tf([13.375,33],[1]);

% create Closed loop TF
H_c = feedback(H_o*C,1);

% Step response metrics
Metrics = stepinfo(H_c)

% Step response graphs
[y,t] = step(H_c);
figure(1)
plot(t,y)
xlabel("Time - [s]")
ylabel("Angular Position - [rad]")
title("Step Response")

% Steady State error
Ess = abs(1-y(end))


