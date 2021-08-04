import serial
import time
import numpy as np

force = serial.Serial("COM8",timeout=2)
pd = serial.Serial("COM10",timeout=2)
pd.flush()
force.flush()
time.sleep(3)
print(pd.write(b'aaa')) #start transmission
pd.read()
fread = []
pdread = []
print("STARTING")
try:
    while 1:
        p=pd.readline()
        f=force.readline()
        fread.append(f)
        pdread.append(p)
except KeyboardInterrupt:
    #now do processing
    print(fread)
    print([len(fread),len(pdread)])
    pd.close()