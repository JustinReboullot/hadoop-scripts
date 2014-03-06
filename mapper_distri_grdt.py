#!/usr/bin/python

import sys
from math import log
from math import exp
import numpy as np

p = len(sys.argv)
grad = np.asmatrix(np.repeat(0,(p-1)).astype(np.float))
loglikelihood = 0

beta = np.matrix([float(i) for i in sys.argv[1:]])

for line in sys.stdin:
	line = line.strip()
	line = line.split()
	line = [float(i) for i in line]
	
	y = line[0]
	x = np.matrix(line[1:p])

	grad += x*(y - 1/(1 + exp(x*beta.T)))

print("{}\t{}".format('grad',grad))
