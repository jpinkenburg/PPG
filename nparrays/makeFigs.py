import numpy as np
import matplotlib.pyplot as plt

def fconv(f):
    f = f*5/1024
    return -1*((0.9914*f - 2.3887)*9.80665)

rbot = 750
ibot = 100
irnum = '6'
rednum = '2'

fir = np.load('force_ir'+irnum+'.npy')
pdir = np.load('pd_ir'+irnum+'.npy')
pcnti = np.load('pcnt_ir'+irnum+'.npy')
fcnti = np.load('fcnt_ir'+irnum+'.npy')
fred = np.load('force_'+rednum+'.npy')
pdred = np.load('pd_'+rednum+'.npy')
pcntr = np.load('pcnt_'+rednum+'.npy')
fcntr = np.load('fcnt_'+rednum+'.npy')

fred = fconv(fred[rbot:])
pdred = pdred[rbot:]*5/1024
fir = fconv(fir[ibot:1200])
pdir = pdir[ibot+20:1200+20]*5/1024


#show force vs time for IR and red
figr,axr = plt.subplots()
axr2 = axr.twinx()
line1, = axr2.plot(np.arange(len(pdred)),pdred,color='#011F5B',linewidth=0.5)
line2, = axr.plot(np.arange(len(fred)),fred,color='#990000',linewidth=2)
axr.set_xlabel("Time (s)")
axr.set_ylabel("Applied Normal Force (N)")
axr2.set_ylabel("PD Reading (V)")
plt.title("Red Light: Force, Photodiode Reading vs Time")

figr,axi = plt.subplots()
axi2 = axi.twinx()
line1, = axi2.plot(np.arange(len(pdir)),pdir,color='#011F5B',linewidth=0.5)
line2, = axi.plot(np.arange(len(fir)),fir,color='#990000',linewidth=2)
axi.set_xlabel("Time (s)")
axi.set_ylabel("Applied Normal Force (N)")
axi2.set_ylabel("PD Reading (V)")
plt.title("IR Light: Force, Photodiode Reading vs Time")

# show force vs pd reading
plt.figure()
plt.scatter(fred,pdred,s=10)
plt.xlabel("Applied Normal Force (N)")
plt.ylabel("Photodiode Reading (V)")
plt.title("Red Light: Photodiode Reading vs Force")

plt.figure()
plt.scatter(fir,pdir,s=10)
plt.xlabel("Applied Normal Force (N)")
plt.ylabel("Photodiode Reading (V)")
plt.title("IR Light: Photodiode Reading vs Force")

#come up with one more epoxy graph

plt.show()