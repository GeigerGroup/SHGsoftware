#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Jul 13 12:06:48 2018

@author: geiger
"""

from optics_calcs.refrIndexData import RefrIndexData

import numpy as np
import matplotlib.pyplot as plt
import scipy.interpolate

class Material:
    
    def __init__(self,name):
        #get wavelength and refr from database
        allData = RefrIndexData()
        self.wavelengths = allData.data[name][0]
        self.refr = allData.data[name][1]
        
        #use interpolate function
        self.f = scipy.interpolate.interp1d(self.wavelengths,self.refr)
    
    #refractive index   
    def n(self,wl):
        return float(self.f(wl))
    
    #plot refractive index + interpolate function
    def plotn(self):
        plt.figure()    
        plt.plot(self.wavelengths,self.refr)
        
        x = np.linspace(self.wavelengths[0],self.wavelengths[-1],num=10000)
        y = self.f(x)
        plt.plot(x,y,'--')
     
    #group index, g = n(lamda) - lamda*(dn/dlamda)
    def g(self,wl):
        #use interpolated univariate spline to be able to calculate deriv
        intfunc = scipy.interpolate.InterpolatedUnivariateSpline(self.wavelengths,self.refr)
        #calculate derivative 
        intfuncderiv = intfunc.derivative()
        g = intfunc(wl) - wl*intfuncderiv(wl)
        return g
        
    
        
        
        
        
    
        
        
    
        
        
        
        