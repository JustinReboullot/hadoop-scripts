#!/bin/bash

alpha=$1 #Step size
shift
beta="$@" #Initialization

#write to an output file
echo "Beta = $beta and alpha = $alpha" #>> iterations_file

maxiter=1
i=0
while [ $i -lt $maxiter ];do #The main loop

	#Do one iteration of the algorithm using hadoop streaming
	./bin/hadoop jar ./share/hadoop/tools/lib/hadoop-streaming-2.2.0.jar \
		-file /home/hduser/hadoop-scripts/mapper_distri_grdt.py \
		-mapper "/home/hduser/hadoop-scripts/mapper_distri_grdt.py $beta" \
		-file /home/hduser/hadoop-scripts/reducer_distri_grdt.py \
		-reducer "/home/hduser/hadoop-scripts/reducer_distri_grdt.py $alpha $beta" \
		-input LogData.txt \
		-output gradient-descent-test
	
	#Transforms the output to something readable by the mapper and the reducer (for the next iteration)
	beta=`./bin/hdfs dfs -cat gradient-descent-test/part-00000`
	beta=${beta/beta_next	[[/}
	beta=${beta/]]/}

	#Supresses the output file that hadoop streaming creates automatically (need to be done)
	./bin/hdfs dfs -rm -R gradient-descent-test
	
	#Write the iteration results to an output file
	echo "At iteration $i$, beta = $beta" #>> iterations_file
	let i++
done

