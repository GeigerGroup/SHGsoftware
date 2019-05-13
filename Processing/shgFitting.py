import math

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from scipy.optimize import curve_fit

def importSHGdata(names,inputpath,outputpath):
    
    #open file for writing scans to
    fScans = open(outputpath+'scans.txt','w+')

    #initialize data frames to hold data
    countsA = pd.DataFrame()
    countsB = pd.DataFrame()
    pos = pd.DataFrame()

    #go through each file
    for name in names:
        #names of each file
        filename = inputpath + '/' + name + '.txt'
        #import countsA (signal),countsB (dark counts), and pos (stage position)
        countsA[name] = pd.read_csv(filename,sep='\t')['countsA']
        countsB[name] = pd.read_csv(filename,sep='\t')['countsB']
        pos[name] = pd.read_csv(filename,sep='\t')['stage']
    
    #determine interval by number of zeros in position
    interval = len(pos[name]) - np.count_nonzero(pos[name])
        
    #define function to turn time wave into scan by taking average of intervals
    def findAverage(series):
        #set number of points per position here
        reshaped = np.reshape(series.values,(int(len(series.values)/interval),interval))
        return pd.Series(np.mean(reshaped,1))

    #apply function to time data to get the scan data
    aveCountsA = countsA.apply(findAverage,axis=0)
    aveCountsB = countsB.apply(findAverage,axis=0)
    pos = pos.apply(findAverage,axis=0)
    del countsA,countsB
    
    #correct for dark counts
    counts = aveCountsA.sub(aveCountsB)
    del aveCountsA,aveCountsB
    

    #create data frame to hold each scan and the position vector
    data = counts.copy()
    data.insert(0,'pos',pos[names[0]])

    #write to file    
    fScans.write(data.to_csv(sep='\t', index=False, header=True))
    fScans.close()

    #plot individual
    plt.figure()
    plt.title('Individual Scan Data')
    for column in pos.columns:
        plt.plot(pos[column],counts[column],'.')
        
    return data

#define fit func
def cosFunc(x, y0, A, f, phi):
    return y0 + A*np.cos(f*x + phi)

#initial fitting function where all parameters are free
def initFit(data):

    #x values from which to plot fit function
    xvalues = np.linspace(0,99.7,1000)

    #data frame to hold initial fitting parameters
    initFitParams = pd.DataFrame(columns=['name','y0','y0error','A','Aerror','f','ferror','phi','phierror'])
    initFitValues = pd.DataFrame({'pos':xvalues})

    #fit, going through column by column and storing fit parameters in initFits
    for column in data.drop('pos',axis=1).columns:
        #calculate guesses for fit func
        y0guess = np.mean(data[column])
        Aguess = (np.amax(data[column])-np.amin(data[column]))/2
        fguess = 0.05;
        phiguess = 0;
        guesses = [y0guess,Aguess,fguess,phiguess]
    
        #fit it
        popt, pcov = curve_fit(cosFunc,data['pos'],
                           data[column],p0=guesses)
        #calculate standard error
        pstd = np.sqrt(np.diag(pcov))
    
        #create row and append it to the dataframe
        tdf = pd.DataFrame({'name':[column],'y0':[popt[0]],'y0error':[pstd[0]],'A':[popt[1]],'Aerror':[pstd[1]],
                         'f':[popt[2]],'ferror':[pstd[2]],'phi':[popt[3]],'phierror':[pstd[3]]})
        initFitParams = initFitParams.append(tdf,ignore_index=True)
    
        #calculate fit and add it to fit values
        initFitValues[column] = cosFunc(xvalues,popt[0],popt[1],popt[2],popt[3])
    

    #resort columns
    columnTitles = ['name','y0','y0error','A','Aerror','f','ferror','phi','phierror']
    initFitParams = initFitParams.reindex(columns=columnTitles)

    #plot the initial fits
    plt.figure()
    plt.title('Init Fits')
    for column in data.drop('pos',axis=1).columns:
        plt.plot(data['pos'],data[column],'.')
        plt.plot(xvalues,initFitValues[column])
        
    return initFitParams, initFitValues

#calculate fAve for second round of fitting
def calcFAve(initFitParams):
    #calculate average of f values, then period
    fAve = initFitParams['f'].abs().mean()
    period = 2*np.pi/fAve
    
    #calculate stdev
    fStd = initFitParams['f'].abs().std()
    periodError = period*(fStd/fAve)
    
    #print
    print('f = '+'%.2f'%period+' +- '+'%.2f'%periodError)
    
    return fAve,fStd

#final fit function where f is held at fAve
def finalFit(data,fAve,fStd):
    
    #x values from which to plot fit function
    xvalues = np.linspace(0,99.7,1000)

    #data frame to hold final fitting parameters and values
    finalFitParams = pd.DataFrame(columns=['name','y0','y0error','A','Aerror','f','ferror','phi','phierror'])
    finalFitValues = pd.DataFrame({'pos':xvalues})

    #go through each column
    for column in data.drop('pos',axis=1).columns:
        #calculate guesses
        y0guess = np.mean(data[column])
        Aguess = (np.amax(data[column])-np.amin(data[column]))/2
        phiguess = 0;
        guesses = [y0guess,Aguess,phiguess]

        #fit it, with f fixed
        popt, pcov = curve_fit(lambda x, y0, A, 
                               phi: cosFunc(x,y0, A, fAve, phi),
                               data['pos'],data[column],p0=guesses)
    
        #calculate standard error
        pstd = np.sqrt(np.diag(pcov))
    
        #create row and append it to the dataframe
        tdf = pd.DataFrame({'name':[column],'y0':[popt[0]],'y0error':[pstd[0]],'A':[popt[1]],'Aerror':[pstd[1]],
                         'f':[fAve],'ferror':[fStd],'phi':[popt[2]],'phierror':[pstd[2]]})                       
        finalFitParams = finalFitParams.append(tdf,ignore_index=True)
    
        #calculate fit and add it to fit values
        finalFitValues[column] = cosFunc(xvalues,popt[0],popt[1],fAve,popt[2])
             
    #calculate phi in degrees
    finalFitParams['phideg'] = np.degrees(finalFitParams['phi'])
    finalFitParams['phidegerror'] = (finalFitParams['phierror']/finalFitParams['phi'])*finalFitParams['phideg']

    #resort columns
    columnTitles = ['name','y0','y0error','A','Aerror','f','ferror','phi','phierror','phideg','phidegerror']
    finalFitParams = finalFitParams.reindex(columns=columnTitles)

    #plot the final fits
    plt.figure()
    plt.title('Final Fits')
    for column in data.drop('pos',axis=1).columns:
        plt.plot(data['pos'],data[column],'.')
        plt.plot(xvalues,finalFitValues[column])
        
    return finalFitParams, finalFitValues

#write to file
def writeToFile(df,outputpath,name):
    f = open(outputpath+name,'w+')
    f.write(df.round(3).to_csv(sep='\t', index=False, header=True))
    f.close()
    
#make amplitudes positive
def makeAmpPositive(df):
    #change all amplitudes to be positive
    df.loc[df['A']<0, 'phideg'] = df.loc[df['A']<0, 'phideg'] -180
    df.loc[df['A']<0, 'phi'] = df.loc[df['A']<0, 'phi'] - math.pi
    df.loc[df['A']<0, 'A'] = -1*df.loc[df['A']<0, 'A']
    return df

    
