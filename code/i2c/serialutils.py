import numpy as np
def removeOutliers(arr):
    for i in range(len(arr)):
        if arr[i] > 850:
            arr[i] = np.mean(arr)
        elif arr[i] < 400:
            arr[i] = np.mean(arr)
    return arr

def smoothover(arr):
    for i in range(5,len(arr)):
        arr[i] = np.sum(arr[i-5:i])/5
    return arr
def getarrs():
    global i,r,rforce,iforce
    i = np.load('ir.npy')
    r = np.load('red.npy')
    rforce = np.load('rforce.npy')
    iforce = np.load('iforce.npy')