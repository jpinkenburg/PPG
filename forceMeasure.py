import serial
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.animation as animation

ir_light = []
ir_force = []
red_light = []
red_force = []
ir_time = []
red_time = []

#irplot, = plt.plot([],[])
#redplot, = plt.plot([],[])

plotlen = 100

def update_plot(color):
    if color == 'i':
        x = ir_force
        y = ir_light
    else:
        x = red_force
        y = red_light
    if len(x) > plotlen:
        x = x[len(x)-plotlen:]
        y = y[len(y)-plotlen:]
    
    if color == 'i':
        irplot.set_xdata(x)
        irplot.set_ydata(y)
    else:
        redplot.set_xdata(x)
        redplot.set_ydata(y)
    plt.draw()

    

s = serial.Serial()
s.port  = 'COM8'
s.open()

input("Press ENTER to start readings: ")
try:
    while(1):
        x=s.readline()
        tex = x.decode()
        tex = tex.split('\t')
        print(tex)
        if tex[0][0] == 'r':
            if int(tex[2]) < 650:
                red_force.append(int(tex[1]))
                red_light.append(int(tex[2]))
                red_time.append(len(red_time))
        elif tex[0][0] == 'i':
            if int(tex[2])<650:
                ir_force.append(int(tex[1]))
                ir_light.append(int(tex[2]))
                ir_time.append(len(ir_time))
        else:
            print("ERROR")
        #update_plot(tex[0][0])

except KeyboardInterrupt:
    s.close()
    plt.figure()
    plt.scatter(ir_force,ir_light)
    plt.xlabel('Force')
    plt.ylabel('Photodiode Reading')
    plt.title('IR: Reading vs Force')
    plt.figure()
    red_force = np.array(red_force)
    red_light = np.array(red_light)
    np.save('red_force.npy',red_force)
    np.save('red_light.npy',red_light)
    plt.scatter(red_force,red_light)
    plt.xlabel('Photodiode Reading')
    plt.ylabel('Force')
    plt.title('Red Light: Reading vs Force')
    fig, ax1 = plt.subplots()
    ax2 = ax1.twinx()
    line1, = ax1.plot(ir_time,ir_force)
    line2, = ax2.plot(ir_time,ir_light,color='orange')
    ax1.set_xlabel('Time')
    ax1.set_ylabel('Force')
    ax2.set_ylabel('Photodiode Reading')
    plt.title('IR Light: Force, Reading vs Time')
    ax1.legend([line1, line2], ['Force', 'Photodiode Reading'])
    fig2, ax3 = plt.subplots()
    ax4 = ax3.twinx()
    line3, = ax3.plot(red_time,red_force,color='#1f77b4')
    line4, = ax4.plot(red_time,red_light,color='magenta')
    ax3.set_xlabel('Time')
    ax3.set_ylabel('Force')
    ax4.set_ylabel('Photodiode Reading')
    plt.title('Red Light: Force, Reading vs Time')
    ax3.legend([line3, line4], ['Force', 'Photodiode Reading'])
    plt.show()