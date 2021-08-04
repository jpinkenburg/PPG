import serial
import numpy as np
import matplotlib.pyplot as plt

s = serial.Serial()
s.port = 'COM10'
s.close()
s.open()

red = []
ir = []
rforce = []
iforce = []

def bitfield(n):
    ans = [int(digit) for digit in bin(n)[2:]] # [2:] to chop off the "0b" part 
    for i in range(8-len(ans)):
        ans.insert(0,0)
    return ans

def conv10(n):
    #print(n)
    s=0
    for i in range(10):
        s += n[i]*2**(9-i)
    return s

def bit_conv(bytes):
    a = bitfield(bytes[0])
    b = bitfield(bytes[1])
    return conv10((a+b)[:10])

s.readline()
s.readline()
a = s.readline()
prev = a[1]%2

print("STARTING COLLECTION")
try: #data collection
    while(1):
        x = s.readline()
        parity = x[1]%2
        if not prev: #if previous is the same parity
            red.append(x)
        else:
            ir.append(x)
        prev = parity

except KeyboardInterrupt: #data processing
    s.close()
    iforce = np.zeros(len(ir))
    rforce = np.zeros(len(red))
    for i in range(len(red)):
        try:
            rprev = red[i]
            rforce[i] = int(rprev[2:].decode().split('_')[0])
            red[i] = bit_conv(rprev)
        except IndexError:
            print(red[i])
            red[i] = -1
    for j in range(len(ir)):
        try:
            iprev = ir[j]
            iforce[j] = int(iprev[2:].decode().split('_')[0])
            ir[j] = bit_conv(iprev)
        except:
            ir[j] = -1
    red = np.array(red)
    ir = np.array(ir)
    np.save('red.npy',red)
    np.save('ir.npy',ir)
    np.save('rforce.npy',rforce)
    np.save('iforce.npy',iforce)
    s.close()

