#!/usr/bin/python

import sys
from math import log
from math import exp
from numpy import matrix

grad = 0

for line in sys.stdin:
	line = line.strip()
	line = line.split()
	line = [float(i) for i in line]

	x = matrix(line[1:])
	beta = matrix([float(i) for i in sys.argv[1:]])

	grad += x*(line[0] - 1/(1 + exp(x*beta.T)))
print("{}\t{}".format('grad',grad))
