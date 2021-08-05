import serial
import time
import numpy as np

force = serial.Serial("COM8",timeout=2)
pd = serial.Serial("COM10",timeout=2)
pd.flush()
force.flush()
pd.flush()
force.flush()
time.sleep(3)
print(pd.write(b'aaa')) #start transmission
#pd.read()
fread = []
pdread = []
print("STARTING")
try:
    while 1:
        p=pd.readline()
        f=force.readline()
        fread.append(f)
        pdread.append(p)
        print(p)
except KeyboardInterrupt:
    #now do processing
    f = []
    fcnt = []
    p = []
    pcnt = []
    for i in range(len(fread)-1):
        try:
            #print(fread[i])
            dec = fread[i].decode().split('\t')
            f.append(int(dec[0]))
            fcnt.append(int(dec[1]))
            dec = pdread[i].decode().split('\t')
            p.append(int(dec[0]))
            pcnt.append(int(dec[1]))
        except:
            if len(f) > len(p):
                f.pop()
            elif len(p) > len(f):
                p.pop()
    f = np.array(f)
    p = np.array(p)
    fcnt = np.array(fcnt)
    pcnt = np.array(pcnt)
    np.save('force.npy',f)
    np.save('fcnt.npy',fcnt)
    np.save('pd.npy',p)
    np.save('pcnt.npy',pcnt)
    x = []
    y = []
    for i in range(len(p)):
        if p[i] > 400:
            y.append(p[i])
            x.append(f[i])

    np.save('force_filtered.npy',x)
    np.save('pd_filtered.npy',y)
    #print(fread[10])
    #print(pdread[10])
    #print([len(fread),len(pdread)])
    pd.close()
    force.close()