# Check all Docker services except for the visualization "viz"
# service and rebalance containers among available swarm nodes
# if a service is not balanced.
#
# NOTE AND DISCLAIMER:
# This script assumes that services are configured to run on
# either worker or manager nodes.

for service in `docker service ls | awk '($2 != "viz" && $2 != "NAME") { print $1 }'`; do
    docker service ps ${service} | awk '($5 == "Running") { print $4 }' > container-nodes.txt
    container_node_count=`cat container-nodes.txt | sort | uniq | wc -l`
    container_count=`cat container-nodes.txt | wc -l`
    if [ $container_count -gt $container_node_count ]
    then
        available_node_count=`docker node ls | awk '($3 == "Ready" || $2 == "*" && $4 == "Ready") { print $1 }' | wc -l`
        if [ $available_node_count -gt $container_node_count ]
        then
            replicas="`docker service inspect ${service} --pretty | grep Replicas | awk '{ print $NF }'`"
            # Note: replicas should equal container_count, right?
            echo "service ${service} needs to be rebalanced to ${replicas} replicas"

            # Rebalance the containers by first scaling down, then up
            docker service scale ${service}=${container_node_count}
            docker service scale ${service}=${replicas}
	else
	    echo "service ${service} can be rebalanced when adding a node"
        fi
    else
        echo "service ${service} does not need to be rebalanced"
    fi
done
