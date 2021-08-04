import serial
import numpy as np
import matplotlib.pyplot as plt

s = serial.Serial("COM10")
rlight = []
ilight = []
rforce = []
iforce = []
s.readline()
s.readline()

while(1):
    try:
        txt = s.readline().decode().split('\t')
        if len(txt) == 3:
            if txt[0] == 'r':
                print(txt)
                rlight.append(int(txt[1]))
                rforce.append(int(txt[2]))
            elif txt[0] == 'i':
                ilight.append(int(txt[1]))
                iforce.append(int(txt[2]))
    except KeyboardInterrupt:
        s.close()
        rlight = np.array(rlight)
        rforce = np.array(rforce)
        ilight = np.array(ilight)
        iforce = np.array(iforce)

        np.save('rlight',rlight)
        np.save('rforce',rforce)
        np.save('ilight',ilight)
        np.save('iforce',iforce)

        plt.scatter(rforce,rlight)
        plt.figure()
        plt.scatter(ilight,iforce)
        plt.show()
        raise(ArithmeticError)