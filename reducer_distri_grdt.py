#!/usr/bin/python

import sys
from numpy import matrix

alpha = float(sys.argv[1])
gradtotal = matrix([0.0,0.0])

for line in sys.stdin:
	grad = line.split('\t')[1]
	grad = grad.lstrip('[[\t')
	grad = grad.strip()
	grad = grad.strip(']]')
	grad = grad.split()
	grad = matrix([float(i) for i in grad])

	beta = line.split('\t')[2]
        beta = beta.lstrip('[[\t')
        beta = beta.strip()
        beta = beta.strip(']]')
        beta = beta.split()
        beta = matrix([float(i) for i in beta])

	gradtotal += grad

beta_next = beta + alpha*gradtotal

print ('{}\t{}'.format('gradtotal', gradtotal))
print (beta_next)

