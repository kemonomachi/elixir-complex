import cmath

def conj(x):
    return x.conjugate()

def signum(x):
    return 0 if x == 0 else x / abs(x)

def cis(theta):
    return cmath.rect(1, theta)

