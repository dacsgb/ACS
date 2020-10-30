Theta_t = Thetas.time;
Theta_r = Thetas.signals(2).values;
Theta_a = Thetas.signals(1).values;
Z_t = Zs.time;
Z_r = Zs.signals(2).values;
Z_a = Zs.signals(1).values;

figure(2)
plot(Theta_t,Theta_r,"--",Theta_t,Theta_a)
xlabel("Time - [s]")
ylabel("Angular Displacement - [rad]")
title("Non Linear System Angular Response")
legend("Theta Ref","Theta")

figure(3)
plot(Z_t,Z_r,"--",Z_t,Z_a)
xlabel("Time - [s]")
ylabel("Linear Displacement - [m]")
title("Non Linear System Linear Response")
legend("Z Ref","Z")