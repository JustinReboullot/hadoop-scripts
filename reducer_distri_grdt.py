#!/usr/bin/python

import sys
import numpy as np

p = len(sys.argv)


alpha = float(sys.argv[1])
beta = np.matrix([float(i) for i in sys.argv[2:(p-1)]])
gradtotal = np.asmatrix(np.repeat(0,(p-2)))

for line in sys.stdin:
	grad = line.split('\t')[1]
	grad = grad.lstrip('[[\t')
	grad = grad.strip()
	grad = grad.strip(']]')
	grad = grad.split()
	grad = np.matrix([float(i) for i in grad])
	gradtotal += grad

beta_next = beta + alpha*gradtotal

print ('{}\t{}'.format('beta_next', beta_next))
