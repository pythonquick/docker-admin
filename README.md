# docker-admin

Collection of bash scripts for docker admin tasks.

## Script docker-swarm-auto-rebalance.sh

By default docker swarm does not redistribute containers among nodes when new
nodes become available. This is by design. See https://github.com/moby/moby/issues/24103

This script can be used to rebalance a docker swarm if the swarm's containers are not balanced.
The swarm can become unbalanced in the following scenario:

* Some worker nodes become unavailable.
* The swarm manager replaces the nodes from the lost nodes onto existing available nodes
* The lost worker nodes become available again

At this point some of the existing nodes contain multiple containers while the
newly available nodes do not contain any containers. Running the script will 
rebalance the containers among the swarm nodes by scaling the replicas down and
up again, while preserving the service availability of the swarm

Note: It is assumed that service containers are distributed among worker _and_ manager nodes
