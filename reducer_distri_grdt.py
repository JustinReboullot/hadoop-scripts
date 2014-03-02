#!/usr/bin/python

import sys
from numpy import matrix

p = len(sys.argv)

alpha = float(sys.argv[1])
beta = matrix([float(i) for i in sys.argv[2:(p-1)]])
gradtotal = matrix([0.0,0.0])

for line in sys.stdin:
	grad = line.split('\t')[1]
	grad = grad.lstrip('[[\t')
	grad = grad.strip()
	grad = grad.strip(']]')
	grad = grad.split()
	grad = matrix([float(i) for i in grad])
	gradtotal += grad

beta_next = beta + alpha*gradtotal

print ('{}\t{}'.format('beta_next', beta_next))
