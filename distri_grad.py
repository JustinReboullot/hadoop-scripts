#!/usr/bin/python

from subprocess import *
import sys
import numpy as np



#call("./bin/hadoop jar ./share/hadoop/tools/lib/hadoop-streaming-2.2.0.jar   -file /home/hduser/hadoop-scripts/mapper_distri_grdt.py -mapper '/home/hduser/hadoop-scripts/mapper_distri_grdt.py 2 2'   -file /home/hduser/hadoop-scripts/reducer_distri_grdt.py -reducer '/home/hduser/hadoop-scripts/reducer_distri_grdt.py 1 2 2'   -input LogData.txt -output gradient-descent-test", shell =True)


call(["./bin/hadoop", "jar", "./share/hadoop/tools/lib/hadoop-streaming-2.2.0.jar",   "-file","/home/hduser/hadoop-scripts/mapper_distri_grdt.py", "-mapper", "'/home/hduser/hadoop-scripts/mapper_distri_grdt.py 2 2'",   "-file", "/home/hduser/hadoop-scripts/reducer_distri_grdt.py", "-reducer", "'/home/hduser/hadoop-scripts/reducer_distri_grdt.py 1 2 2'",   "-input", "LogData.txt", "-output", "gradient-descent-test"])



call("./bin/hdfs dfs -copyToLocal gradient-descent-test/part-00000", shell=True)
dir = check_output("pwd",shell=True).strip()
with open("{}/part-00000".format(dir)) as file:
	beta = file.readline()
	beta = beta.split('\t')[1]
        beta = beta.lstrip('[[\t')
        beta = beta.strip()
        beta = beta.strip(']]')
        beta = beta.split()
        beta = np.matrix([float(i) for i in beta])	
print(beta)

#supress the local output file
call("rm part-00000", shell=True)
#supres the output directory
call("./bin/hdfs dfs -rm -R gradient-descent-test/", shell=True)





#output = check_output("head -n 10 /home/hduser/hadoop-scripts/LogData.txt | /home/hduser/hadoop-scripts/mapper_distri_grdt.py 2 2 | sort | /home/hduser/hadoop-scripts/reducer_distri_grdt.py 2 2 2", shell=True)

a = "2"


#p1 = Popen(["head", "-n", "10", "/home/hduser/hadoop-scripts/LogData.txt"], stdout=PIPE)
#p2 = Popen(["/home/hduser/hadoop-scripts/mapper_distri_grdt.py", a, "2"],stdin=p1.stdout, stdout=PIPE)
#p3 = Popen(["sort"],stdin=p2.stdout, stdout=PIPE)
#p4 = Popen(["/home/hduser/hadoop-scripts/reducer_distri_grdt.py", "2", "2", "2"],stdin=p3.stdout, stdout=PIPE)

#output = process.communicate()[0]


#print(output)
