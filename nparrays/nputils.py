import numpy as np
def load_arrs():
    fir = np.load('force_ir1.npy')
    fred = np.load('force_2.npy')
    pdred = np.load('pd_2.npy')
    pdir = np.load('pd_ir1.npy')
    pcntr = np.load('pcnt_2.npy')
    pcnti = np.load('pcnt_ir1.npy')
    fcntr = np.load('fcnt_2.npy')
    fcnti = np.load('fcnt_ir1.npy')
    return fir,fred,pdred,pdir,pcntr,pcnti,fcntr,fcnti

def showcomms():
    print("fir,fred,pdred,pdir,pcntr,pcnti,fcntr,fcnti = n.load_arrs()")