#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Oct 24 23:53:06 2017

@author: pohno
"""

#import constants
from scipy import constants

import math

import numpy as np


#define constants
eR = 78
e0 = constants.epsilon_0
R = constants.R
kB = constants.k
F = constants.physical_constants['Faraday constant'][0]
T = 298.15
e = constants.e
N = constants.N_A

def debyeLength(C):
    return np.sqrt((eR*e0*R*T)/(2*F**2*C*1000))

def GCpotential(C,sigma):
    return (2*kB*T/e)*np.arcsinh(sigma/np.sqrt(8000*kB*T*N*C*e0*eR))


#CRC "Ionic Conductivity and Diffusion at Infinite Dilution"
# units are 10^-4 m^2 S mol^-1
infDilConds={
        #alkali cations
        'Li+':38.66,
        'Na+':50.08,
        'K+':73.48,
        'Rb+':77.8,
        'Cs+':77.2,
        
        #halide anions
        'F-':55.4,
        'Cl-':76.31,
        'Br-':78.1,
        'I-':76.8,
        
        #other 
        'H+':349.65,
        'HCO3-':44.5}


#Debye-Huckel-Onsager 1927. Intro to Aqueous Electrolyte Solutions page 487
#good up to ~1 mM
#molcond = molcondinf - (A + B*molcondinf)*sqrt(c)
    
def DHOmolcond(ion1,ion2,C):
    #for 1:1 electrolyte
    A = 60.58 #cm^2 mol^(-3/2) dm^(3/2)
    B = 0.229 #mol^(-1/2) dm^(3/2)
    molcondinf = infDilConds[ion1] + infDilConds[ion2]
    return (molcondinf -(A + B*molcondinf)*np.sqrt(C))

def DHOcond(ion1,ion2,C):
    return np.multiply(C,DHOmolcond(ion1,ion2,C)*1000)







    
    
