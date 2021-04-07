clc
clear

P = tf(10,[1 2  -7]);
%%%%%  insert  your  controller  here  %%%%%
a = 40*(pi/180);
M = (1 + sin(a))/(1-sin(a));
w = 6.25;
C = tf([M, w*sqrt(M)],[1,w*sqrt(M)])
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Delay = 0.4; % Delay  in  seconds
D = tf(1,1,'InputDelay',Delay); % Delay  transfer  function
H_YR = feedback(C*P,D); % Closed -loop  transfer  function  with  feedback  delay
[y,t] = step(H_YR);
writematrix([t,y])