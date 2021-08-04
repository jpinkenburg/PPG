def removeOutliers(arr):
    for i in range(len(arr)):
        if arr[i] > 850:
            arr[i] = np.mean(arr)
        elif arr[i] < 400:
            arr[i] = np.mean(arr)
