import numpy as np
from scipy.signal import *
import matplotlib.pyplot as plt

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