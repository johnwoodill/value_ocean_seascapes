import numpy as np
import matplotlib.pyplot as plt
import pandas as pd 
import imageio
import glob


#%%
def chebspace(npts):
    t = (np.array(range(0,npts)) + 0.5) / npts
    return -np.cos(t*math.pi)


def chebmat(u, N):
    T = np.column_stack((np.ones(len(u)), u))
    for n in range(2, N+1):
        Tnext = 2*u*T[:, n-1] - T[:, n-2]
        T = np.column_stack((T,Tnext))
    return T


#%%
class Cheby(object):
#https://www.embeddedrelated.com/showarticle/152.php
    def __init__(self, a, b, *coeffs):
        self.c = (a+b)/2.0
        self.m = (b-a)/2.0
        self.coeffs = np.array(coeffs, ndmin=1)
    def rangestart(self):
        return self.c-self.m
    def rangeend(self):
        return self.c+self.m
    def range(self):
        return (self.rangestart(), self.rangeend())
    def degree(self):
        return len(self.coeffs)-1
    def truncate(self, n):
        return Cheby(self.rangestart(), self.rangeend(), *self.coeffs[0:n+1])
    def asTaylor(self, x0=0, m0=1.0):
        n = self.degree()+1
        Tprev = np.zeros(n)
        T     = np.zeros(n)
        Tprev[0] = 1
        T[1]  = 1
        # evaluate y = Chebyshev functions as polynomials in u
        y     = self.coeffs[0] * Tprev
        for co in self.coeffs[1:]:
            y = y + T*co
            xT = np.roll(T, 1)
            xT[0] = 0
            Tnext = 2*xT - Tprev
            Tprev = T
            T = Tnext
        # now evaluate y2 = polynomials in x
        P     = np.zeros(n)
        y2    = np.zeros(n)
        P[0]  = 1
        k0 = -self.c/self.m
        k1 = 1.0/self.m
        k0 = k0 + k1*x0
        k1 = k1/m0
        for yi in y:
            y2 = y2 + P*yi
            Pnext = np.roll(P, 1)*k1
            Pnext[0] = 0
            P = Pnext + k0*P
        return y2
    def __call__(self, x):
        # Calculate y given x with coefficients
        xa = np.array(x, copy=False, ndmin=1)
        u = np.array((xa-self.c)/self.m)
        Tprev = np.ones(len(u))
        y = self.coeffs[0] * Tprev
        if self.degree() > 0:
            y = y + u*self.coeffs[1]
            T = u
        for n in range(2,self.degree()+1):
            Tnext = 2*u*T - Tprev
            Tprev = T
            T = Tnext
            y = y + T*self.coeffs[n]
        return y
    def __repr__(self):
        return "Cheby%s" % (self.range()+tuple(c for c in self.coeffs)).__repr__()
    @staticmethod
    def fit(func, a, b, degree):
        N = degree+1
        u = chebspace(N)
        x = (u*(b-a) + (b+a))/2.0
        y = func(x)
        T = chebmat(u, N=degree)
        c = 2.0/N * np.dot(y,T)
        c[0] = c[0]/2
        return Cheby(a,b,*c)


#%%
def fn(x):
    return [( (1/3)*(d**3) + 2*(d**2) + d - 10) for d in x]


#%% fn approx
c = Cheby.fit(fn, -100, 100, 2)
y_c = c(np.arange(-100, 100, 1))

plt.plot(np.arange(-100, 100, 1), fn(np.arange(-100, 100, 1)))
plt.plot(np.arange(-100, 100, 1), y_c)
plt.show()


#%% Sine approx
c = Cheby.fit(np.sin, 0, math.pi/2, 2)
y_c = c(np.arange(0, np.pi/2, 0.05))

plt.plot(np.arange(0, np.pi/2, 0.05), y_c)
plt.plot(np.arange(0, np.pi/2, 0.05), np.sin(np.arange(0, np.pi/2, 0.05)))
plt.show()


#%% Random point approx
# Setup space
N = 50
a = 0
b = 50

# Get nodes
u = chebspace(N)
x = (u*(b-a) + (b+a))/2.0

# Get Cheby Matrices
T = chebmat(u, N=N)

# Get random numbers
y = np.random.normal(size=N)

# Get Chebychev coefficients
coeffs = 2.0/N * np.dot(y, T)
coeffs[0] = coeffs[0]/2


# Calculate Chebychev polynomial functions across nodes
x = [np.arange(a, b, 1)]
c = (a + b)/2.0
m = (b - a)/2.0

# Setup arrays for calculations
xa = np.array(x, copy=False, ndmin=1)
u = np.array((xa-c)/m)
Tprev = np.ones(len(u))
y = coeffs[0] * Tprev

# Loop through each node and update approximation
if N > 0:
    y = y + u*coeffs[1]
    T = u
lst_ = []
for n in range(2, N+1):
    Tnext = 2*u*T - Tprev
    Tprev = T
    T = Tnext
    y = y + T*coeffs[n]
    lst_.append(y)


# Generate movie
#%%
for i in np.arange(len(lst_)):
    plt.clf()
    plt.plot(np.arange(0, len(y.ravel())), y.ravel(), color='black')
    plt.plot(np.arange(0, len(y.ravel())), lst_[i].ravel(), color='red')
    plt.annotate(f"Chebychev Nodes: {format(i+2, '02')}", (33, 2.65), color='red')
    plt.ylim(-3, 3)
    plt.savefig(f"figs/chebychev_ex/{format(i, '02')}_chebyapprox.png")
    plt.clf()

filenames = sorted(glob.glob('figs/chebychev_ex/*.png'))
filenames

images = []
for filename in filenames:
    images.append(imageio.imread(filename))
imageio.mimsave('figs/chebychev_ex/animation.gif', images, duration=.5)






