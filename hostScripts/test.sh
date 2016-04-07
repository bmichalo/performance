cpumask=0
num_queues=$1

for i in `seq 1 $num_queues`; do
	cpumask=cpumask|1
	cpumask=cpumask<<2
	echo "num_queues=$num_queues .... cpumask=$cpumask"
done

