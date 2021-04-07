clc
clf

%% System constatnts
m1 = 0.25;
m2 = 1;
l = 0.5;
g = 9.8;
b = 0.05;

%% Start Problem 2
disp("Problem 2")

A = tf([1/m2],[1,b/m2,0]);
B = tf([-m1*g/m2],[1,b/m2,0]);
C = tf([2*b/(m2*l),0],[1,0,(-2*(m1+m2)*g)/(m2*l)]);
D = tf([-2/(m2*l)],[1,0,(-2*(m1+m2)*g)/(m2*l)]);

h1 = (B*D+A)/(B*C + 1);
h2 = (D*A + D)/(B*C + 1);
Hmimo = [h1;h2]

pole(Hmimo)


%% Start Problem 5
disp("Problem 5")

% TF consts
a = -2/(m2*l);
b = -2*(m1+m2)*g/(m2*l);

% Hol
P1 = tf([a],[ 1,0,b])

% C
Kp1 = (160-b)/a;
Kd1 = 24/a;
C1 = tf([Kd1, Kp1],[1])

% Hcl
P1cl = feedback(C1*P1,1)

% Simulate
stepinfo(P1cl)
isstable(P1cl)
figure(1)
step(P1cl)

%% Start Problem 7
disp("Problem 7")

% TF Constants
q = g*a*Kp1;
d = a*Kp1 + b;

% Hol
H0 = tf([a*Kp1],[a*Kp1+b]);
P2 = tf([g],[ 1,0,0]);
P2ol = H0*P2

% Controller
Kp=  0.0001;
Kd = 0.02;
C2 = tf([Kd,Kp],[1])

% Closed loop
P2cl = feedback(C2*P2ol,1)

% Simulate
stepinfo(P2cl)
isstable(P2cl)
figure(2)
step(P2cl);

%% Start Problem 10
disp("Problem 10")

HTZr = minreal((C1*C2*P2)/(C1*C2*P1*P2+C1*P1+1))
isstable(HTZr)

HZZr = minreal((C1*C2*P1*P2)/(C1*C2*P1*P2+C1*P1+1))
isstable(HZZr)