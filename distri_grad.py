#!/usr/bin/python

from subprocess import *
import sys


#output = subprocess.check_output("head -n 10 /home/hduser/hadoop-scripts/LogData.txt | /home/hduser/hadoop-scripts/mapper_distri_grdt.py 2 2 | sort | /home/hduser/hadoop-scripts/reducer_distri_grdt.py 2", shell=True)

a = "2"


p1 = Popen(["head", "-n", "10", "/home/hduser/hadoop-scripts/LogData.txt"], stdout=PIPE)
p2 = Popen(["/home/hduser/hadoop-scripts/mapper_distri_grdt.py", a, "2"],stdin=p1.stdout, stdout=PIPE)
p3 = Popen(["sort"],stdin=p2.stdout, stdout=PIPE)
p4 = Popen(["/home/hduser/hadoop-scripts/reducer_distri_grdt.py", "2"],stdin=p3.stdout, stdout=PIPE)

output = p4.communicate()[0]


print(output)
