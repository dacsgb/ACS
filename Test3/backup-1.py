# To add a new cell, type '# %%'
# To add a new markdown cell, type '# %% [markdown]'
# %% [markdown]
# Diego Colón
# 
# Exam 3 - Solution
# 
# November 20, 2020
# 

# %%
# Import necessary libraries
import cmath
import numpy as np
from scipy.signal import *
from scipy.optimize import fsolve
import matplotlib.pyplot as plt


# %%
# Transfer function Algebra
def ClosedLoop(sys,cont):
    CLn = np.poly1d(sys.num)*np.poly1d(cont.num)
    CLd = np.poly1d(sys.den)*np.poly1d(cont.den) + CLn
    return TransferFunction(CLn.c,CLd.c)

# Required code for loop shaping
class Design():
    def __init__(self,tf,name=None):
        self.tf = tf
        self.name = name

class Analyze():
    def __init__(self,System):
        self.L= [System]
        self.CL = None

    def addDesign(self,cont):
        num = np.poly1d(self.L[-1].tf.num)* np.poly1d(cont.tf.num)
        den = np.poly1d(self.L[-1].tf.den)* np.poly1d(cont.tf.den)
        self.L.append(Design(TransferFunction(num,den),name=cont.name))
    
    def replaceDesign(self,cont,):
        num = np.poly1d(self.L[-2].tf.num)* np.poly1d(cont.tf.num)
        den = np.poly1d(self.L[-2].tf.den)* np.poly1d(cont.tf.den)
        self.L[-1] = (Design(TransferFunction(num,den),name=cont.name))

    def ClosedLoop(self):
        CLn = np.poly1d(self.L[-1].tf.num)
        CLd = np.poly1d(self.L[-1].tf.num)+np.poly1d(self.L[-1].tf.den)
        self.CL = TransferFunction(CLn.c,CLd.c)

    def CLBode(self):
        if self.CL != None:
            ω, m, ϕ = self.CL.bode()

            plt.figure(1)
            plt.title("Bode Magnitude Plot")
            plt.semilogx(ω, m)
            plt.xlabel("w - [rad/s]")
            plt.ylabel("M - [dB]")
            plt.grid(which='major', linestyle='-', linewidth='0.5', color='black')
            plt.grid(which='minor', linestyle=':', linewidth='0.5', color='black')
            
            plt.figure(2)
            plt.title("Bode Phase Plot")
            plt.semilogx(ω, ϕ)
            plt.xlabel("w - [rad/s]")
            plt.ylabel("phi - [deg]")
            plt.grid(which='major', linestyle='-', linewidth='0.5', color='black')
            plt.grid(which='minor', linestyle=':', linewidth='0.5', color='black')
   
        else:
            print("No closed loop TF")

    def Bode(self,display=True):
        for l in self.L:
            ω, m, ϕ = l.tf.bode(np.linspace(1e-2,1e2,num = 4000))

            plt.figure(1)
            plt.semilogx(ω,m,label=l.name)

            plt.figure(2)
            plt.semilogx(ω,ϕ,label=l.name)

        plt.figure(1)
        plt.title("Bode Magnitude Plot")
        plt.xlabel("w - [rad/s]")
        plt.ylabel("M - [dB]")
        plt.grid(which='major', linestyle='-', linewidth='0.5', color='black')
        plt.grid(which='minor', linestyle=':', linewidth='0.5', color='black')
        plt.legend()

        plt.figure(2)
        plt.title("Bode Phase Plot")
        plt.xlabel("w - [rad/s]")
        plt.ylabel("phi - [deg]")
        plt.grid(which='major', linestyle='-', linewidth='0.5', color='black')
        plt.grid(which='minor', linestyle=':', linewidth='0.5', color='black')
        plt.legend()

        if display:
            plt.show()

# %% [markdown]
# 1) Assume that you performed a sine-sweep experiment on an singleloop  series  RLC  circuit  with  voltage  as  the  input  and  current  as  the  output  and  got  the following results: 
# 
# $\omega  = [0.01,0.1,1,10,100,1000][\frac{rad}{s}]$, $M  = [10,10,10,1,0.1,0.01][A]$
# 
# Design a controller so that the bandwidth of the closed-loop is approximately 50 $[\frac{rad}{s}]$

# %%
# Create data arrays
omega = np.array([0.01,0.1,1,10,100,1000])
M = np.array([10,10,10,1,0.1,0.01])

# Find the magnitude in [dB]
M_db = 20*np.log10(M)

# Plot the bode magnitude plot
plt.figure(1)
plt.semilogx(omega,M_db,"o--",label="Data")
plt.title("Bode Magnitude Plot")
plt.xlabel("omega - [rad/s]")
plt.ylabel("M - [dB]")
plt.grid(which='major', linestyle='-', linewidth='0.5', color='black')
plt.grid(which='minor', linestyle=':', linewidth='0.5', color='black')
plt.legend()
plt.show()

# %% [markdown]
# Based on the shape of the data, it can be expected that the RLC circuit can be modeled as a first order system with a transfer function of the type 
# 
# $M(s) = G_{DC}\frac{\omega_{0}}{s+\omega_{0}}$
# 
# where:
# 
# $G_{DC} = 10^{\frac{20}{20}} = 10$
# 
# $\omega_{0}$ is the frequency where there is a loss of -3$[dB]$, meaning $\omega_{0} = \frac{23}{20} [\frac{rad}{s}] = 1.15 [\frac{rad}{s}] $
# 
# Leaving the system transfer fucntion to be $M(s) = 10\frac{1.15}{s + 1.15}$
# 
# 
# From the bode plot above it can be seen that the bandwidth, which is approximately equal to $\omega_{gc}$, is 10 $[\frac{rad}{s}]$. This means that  $\omega_{gc}$ must increase by approximately a factor of 5. To do this, the loop shaping method will be used through the python functions in the beginning of this document.
# %% [markdown]
# The figures below show that although the identified transfer function is close to the measured model, they are not the same. This is to be expected when measuring a system and estimating its parameters. 

# %%
model = Design(TransferFunction([10*1.15],[1,1.15]),name="Model")
Loop1 = Analyze(model)
Loop1.Bode()

# %% [markdown]
# Since the objective is to make a controller so that the bandwidth of the closed-loop is approximately 50 $[\frac{rad}{s}]$, the inverse of the time constant for the transfer function must be around 50. Using a proportional controller could achieve this:
# 
# $\frac{C{_p}M}{1 + C{_p}M} =10 \frac{1.15K_p}{s + 11.5K_p + 1.15}$
# 
# leads to $11.5K_p \approx 11.5K_p + 1.15 \approx 50 $
# 
# Solving the expressing above for $K_p$, $K_p \in [\frac{977}{230},\frac{100}{23}] $

# %%
Cp_1 = Design(TransferFunction([977/230],[1]),name="Cp-1")
Loop1.addDesign(Cp_1)
Loop1.Bode()

# %% [markdown]
# Checking the stability of this closed loop system shows that the controller is stable
# 

# %%
sys1 = TransferFunction([11.5],[1,1.15])
cont = TransferFunction([997/230],[1])
CL = ClosedLoop(sys1,cont)

t, y = step(CL)
plt.plot(t, y)
plt.xlabel('Time - [s]')
plt.ylabel('M - [A]')
plt.title('Step response with Proportinal Controller')
plt.grid()
plt.show()

# %% [markdown]
# (Bonus): Based on the availabe information, can you tell what the capacitance of the circuit is?
# 
# Since the data can be modeled as a first order system, 
# %% [markdown]
# 2) For the inverted Pendulum $P(s) = \frac{10}{s^2 + 2s -7}$:
# 
# A) Calculate the time delay margin of the closed loop under the proportional controller with $K_p = 1$
# 
# B) What  is  the  maximum  possible  time  delay  margin  you  can  get  using  a proportional controller while keeping the closed loop BIBO stable?
# 
# C) Design a controller such that the time delay margin of the closed loop is at least 0.35 s.
# 
# D) Test your controller under delay and provide the step response plots for a delay of 0.34s.  Is the behavior of the system as expected?  If not, why not?
# 
# E) Using the same code as above, provide the step response plots for a delaythat is larger than the time delay margin of the closed loop corresponding to your final design.  Is the behavior of the system as expected?  If not, why not?
# %% [markdown]
# The general equation for the the closed-loop transfer function of the pendulum under a proportional controller is given by:
# 
# $C_p P(s) = \frac{10K_p}{s^2 +2s + (10K_p -7)}$
# 
# with the magnitude, phase and time delay margins being:
# 
# $m = |C_pP(s)|_{dB} = 20log_{10}(\frac{10K_p}{s^2 +2s + (10K_p -7)})$
# 
# $\phi = \angle C_p P(s) = arctan(\frac{\Im(C_p P(s))}{\Re(C_p P(s))})$
# 
# $t_{d} = \frac{\phi}{\omega_{gc}}$; $ \omega_{gc} \ni m = 0$
# 
# For question 2, the following functions are used to calculate the magnitude and phase of P under a proportional controller.

# %%
j = 0 + 1j

def Mag(w,K):
    H = (10*K)/((w*j)**2 + (2*w*j) + (10*K-7))
    return 20*np.log10(np.linalg.norm([H.real,H.imag]))

def Phase(w,K):
    H = (10*K)/((w*j)**2 + (2*w*j) + (10*K-7))
    return np.arctan(H.imag/H.real)

def TDM(k):
    res = fsolve(Mag,1,args=k)
    w_gc = res[0]
    return Phase(w_gc,k)/w_gc, w_gc

# %% [markdown]
# A)
# Using the equations above and a root finding algorithm, $\omega_{gc}$ is found and from there the Time delay margin is computed.

# %%
td = TDM(1)
print("Time delay = {:.3f} [s] @ w_gc = {:.3f} [rad/s]".format(td[0], td[1]))

# %% [markdown]
# B)
# 
# The Routh criteria for a second order system states all coefficients of the characteristic polynomial must be of the same sign. This restricts the possible values of $K_p$ to $K_p \in (\frac{7}{10}, \infty)$
# 
# Below, the Time delay margin is calculated for different values of $K_p$ and plotted

# %%

I = np.linspace(0,75,num=190)
k = []
t_d = []
w_gc = []

for i in I:
    v = (7/10)*(1 + i/100)
    t, w = TDM(v)
    k.append(v)
    t_d.append(t)
    w_gc.append(w)

plt.figure(1)
plt.title("Time Delay Margin vs. Kp")
plt.plot(k,t_d)
plt.xlabel("Kp")
plt.ylabel("Time Delay Margin- [s]")
plt.show()

# %% [markdown]
# C)
# 
# From the plot above, it can be seen that a proportional with values of $K_P$ below ___ yeild the required time delay margins

# %%
P = TransferFunction([10],[1,2,-7])
Pendulum = Design(P,name="Pendulum")
Loop2 = Analyze(Pendulum)
Cp_2 = Design(TransferFunction([0.75],[1]),name="Cp")
Loop2.addDesign(Cp_2)
Loop2.ClosedLoop()
Loop2.CLBode()

# %% [markdown]
# D)
# 
# something
# 
# %% [markdown]
# E) 
# 
# sym

