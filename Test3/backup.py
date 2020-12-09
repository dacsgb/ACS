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
import numpy as np
from scipy.signal import *
import matplotlib.pyplot as plt


# %%
# Transfer function Algebra
def CloosedLoop(sys,cont):
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

    def addDesign(self,cont):
        num = np.poly1d(self.L[-1].tf.num)* np.poly1d(cont.tf.num)
        den = np.poly1d(self.L[-1].tf.den)* np.poly1d(cont.tf.den)
        self.L.append(Design(TransferFunction(num,den),name=cont.name))
    
    def replaceDesign(self,cont,):
        num = np.poly1d(self.L[-2].tf.num)* np.poly1d(cont.tf.num)
        den = np.poly1d(self.L[-2].tf.den)* np.poly1d(cont.tf.den)
        self.L[-1] = (Design(TransferFunction(num,den),name=cont.name))

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
# 
# (Bonus): Based on the availabe information, can you tell what the capacitance of the circuit is?

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
model = Design(TransferFunction([11.5],[1,1.15]),name="Model")
Loop = Analyze(model)
Loop.Bode()

# %% [markdown]
# Since the objective is to make a controller so that the bandwidth of the closed-loop is approximately 50 $[\frac{rad}{s}]$, a proportinal controller would be a logical next step.
# 
# The gain for $C_p$ can be calculated by finding the difference between the gain at $\omega = 50 [\frac{rad}{s}]$ and 0, then converting that value to linear units.
# 
# $K_{p} = 10^{\frac{-M_{dB}(\omega_{bw})}{20}} = 10^{\frac{4}{9}} \approx 2.782$

# %%
Cp_1 = Design(TransferFunction([10**(4/9)],[1]),name="Cp-1")
Loop.addDesign(Cp_1)
Loop.Bode()

# %% [markdown]
# This value for $K_p$ was not enough to reach the required bandwidth, there we iterate increasing $K_p$ until $\omega_{gc} \approx 50 [\frac{rad}{s}]$
# 
# The final value for $K_p$ identified was 4.5

# %%
Cp_f = Design(TransferFunction([4.5],[1]),name="Cp-final")
Loop.replaceDesign(Cp_f)
Loop.Bode()

# %% [markdown]
# Checking the stability of this closed loop system
# 

# %%
sys1 = TransferFunction([11.5],[1,1.15])
cont = TransferFunction([4.5],[1])
CL = CloosedLoop(sys1,cont)

t, y = step(CL)
plt.plot(t, y)
plt.xlabel('Time - [s]')
plt.ylabel('M - [A]')
plt.title('Step response for Proportinal Controller')
plt.grid()
plt.show()

# %% [markdown]
# (Bonus):
# 
# Since the data can be modeled as a first order system, 
# %% [markdown]
# 2) For the inverted Pendulum $P(s) = \frac{10}{s^2 + 2s -7}$:
# 
# %% [markdown]
# A) Calculate the time delay margin of the closed loop under the proportional controller with $K_p = 1$

# %%
P = TransferFunction([10],[1,2,-7])
Loop = Design(P,name="Pendulum")
Loop = Analyze(model)
Cp_2 = Design(TransferFunction([1],[1]),name="Cp")
Loop.addDesign(Cp_2)
Loop.Bode()

# %% [markdown]
# B) What  is  the  maximum  possible  time  delay  margin  you  can  get  using  aproportional controller while keeping the closed loop BIBO stable?
# %% [markdown]
# C) Design a controller such that thetime delay margin of the closed loopis at least 0.35 s.
# %% [markdown]
# D) Test your controller under delay and provide thestep response plots for a delay of 0.34 s.  Is the behavior of the system as expected?  If not, why not?
# %% [markdown]
# E) Using the same code as above, provide the step response plots for a delaythat is larger than the time delay margin of the closed loop corresponding to your final design.  Is the behavior of the system as expected?  If not, why not?

