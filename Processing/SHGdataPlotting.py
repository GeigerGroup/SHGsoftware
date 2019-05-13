#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Jun  4 18:21:04 2018

@author: geiger
"""
import os

import pandas as pd

import numpy as np

os.chdir('/Users/geiger/Box Sync/Science/Simulations/Simulations/Python')
import conductivities as cond

import matplotlib.pyplot as plt

os.chdir('/Users/geiger/Box Sync/Science/Data/SHG/2018/040718')


frame1 = pd.read_csv('run1modified.txt',sep='\t')
frame2 = pd.read_csv('run2modified.txt',sep='\t')

frame1['conc'] = cond.naclConc(frame1['cond'])
frame2['conc'] = cond.naclConc(frame2['cond'])

data = frame2

fig = plt.figure()
ax = fig.add_subplot(3,1,1)
ax.plot(data['time'],data['counts'])
ax = fig.add_subplot(3,1,2)
ax.plot(data['time'],data['conc'])
ax.set_yscale('log')
ax = fig.add_subplot(3,1,3)
ax.plot(data['time'],data['pH'])

cm = plt.get_cmap("cool")
col = cm(data['time']/(7000))


fig = plt.figure()
plt.scatter(data['conc'],data['counts'],c=col)
plt.xscale('log')
plt.xlim((1e-6, 1))


from mpl_toolkits.mplot3d import Axes3D

fig = plt.figure()
ax = Axes3D(fig)

# Create Map
cm = plt.get_cmap("cool")
col = cm(data['counts']/(8000))

#plot with log scale work around
ax.scatter(np.log10(data['conc']),data['pH'], data['counts'],c=col)
xticks = [1e-5, 1e-4, 1e-3, 1e-2, 1e-1, 1e-0]
ax.set_xticks(np.log10(xticks))
ax.set_xticklabels(xticks)
plt.show()