#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Oct 19 15:47:25 2017

Calculate SHG correction factor for absorptive-dispersive terms

@author: pohno
"""
#import math
import math

import numpy as np

#import refractive index
from optics_calcs.material import Material

#import constants
from scipy import constants

def reflAngle(theta):
    return theta


def reflCoefP(theta,n1,n2): 
    num = n1*np.sqrt(1-((n1/n2)*np.sin(np.radians(theta)))**2) - n2*np.cos(np.radians(theta))
    den = n1*np.sqrt(1-((n1/n2)*np.sin(np.radians(theta)))**2) + n2*np.cos(np.radians(theta))
    
    ret = (num/den)**2  
    return ret


def reflCoefS(theta,n1,n2):
    num = n1*np.cos(np.radians(theta)) - n2*np.sqrt(1-((n1/n2)*np.sin(np.radians(theta)))**2)
    den = n1*np.cos(np.radians(theta)) + n2*np.sqrt(1-((n1/n2)*np.sin(np.radians(theta)))**2)

    ret = (num/den)**2
    return ret

def transAngle(theta,n1,n2):
    return np.degrees(np.arcsin((n1/n2)*np.sin(np.radians(theta))))


def transCoefP(theta,n1,n2):
    return 1 - reflCoefP(theta,n1,n2)


def transCoefS(theta,n1,n2):
    return 1 - reflCoefS(theta,n1,n2)

#returns angular frequency from wl in nanometers
def omegaFromWL(wl):
    return 2*math.pi*constants.c/(wl*10**-9)

#returns wl in nm from omega
def WLfromOmega(omega):
    return 2*math.pi*constants.c/(omega)*10**9


def kFromWL(wl,n):
    return 2*math.pi*n/(wl*10**-9)


def sfgOutput(wl1,wl2,theta1,theta2,mat):
    
    mat = Material(mat)
    
    n1 = mat.n(wl1)
    n2 = mat.n(wl2)
    
    omega1 = omegaFromWL(wl1)
    omega2 = omegaFromWL(wl2)
    omega0 = omega1 + omega2
    
    wl0 = WLfromOmega(omega0)
    n0 = mat.n(wl0)
    
    theta0 = np.round(np.degrees(np.arcsin((n1*omega1*np.sin(np.radians(theta1))+
     n2*omega2*np.sin(np.radians(theta2)))/(n0*omega0))),4)
    
    return (theta0, wl0)


def WLfromWN(wn):
    return 10**7/wn


def WNfromWL(wl):
    return 10**7/wl


def deltaKZ(wl1, wl2, theta1, theta2, mat1, mat2):
    # calculate output angle and wavelength
    (theta0, wl0) = sfgOutput(wl1, wl2, theta1, theta2, mat1)

    # calculate each omega
    omega1 = omegaFromWL(wl1)
    omega2 = omegaFromWL(wl2)
    omega0 = omegaFromWL(wl0)

    # get media so can have output wavelengths
    med1 = Material(mat1)
    med2 = Material(mat2)

    # calculate each angle in the second medium
    theta0 = np.radians(transAngle(theta0, med1.n(wl0), med2.n(wl0)))
    theta1 = np.radians(transAngle(theta1, med1.n(wl1), med2.n(wl1)))
    theta2 = np.radians(transAngle(theta2, med1.n(wl2), med2.n(wl2)))

    # get speed of light
    c = constants.c

    # individual kiz
    k1z = (1 / c) * (omega1 * med2.n(wl1) * np.cos(theta1))
    k2z = (1 / c) * (omega2 * med2.n(wl2) * np.cos(theta2))
    k0z = (1 / c) * (omega0 * med2.n(wl0) * np.cos(theta0))

    # find deltaKZ
    deltaKZ = k1z + k2z + k0z

    return deltaKZ



    
    
    
    

