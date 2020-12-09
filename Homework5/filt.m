fl = 16;
fh = 160;

w1 = 2*pi*fl*(1+0.1);
w2 = 2*pi*fh*(1-0.1);

k = w1^2/w2;
z = [w2];
p = [w1,w1];
%sys = zpk(z,p,k)

num = [w1^2];
den = [1, 2*w1/sqrt(2), w1^2]
%sys = tf(num,den)


[n,d] = butter(2,32*pi*(1+0.1),'low','s')
sys = tf(n,d)

bode(sys)
