pod_name=$1

# step 1: get an array of container names within the specified pod
namespace=$(kubectl get pods $pod_name -o=jsonpath='{.metadata.namespace}')

containers=$(kubectl get pods -n $namespace $pod_name -o jsonpath='{.spec.containers[*].name}')

# step 2: find the node this pod runs on
node=$(kubectl get pod "$pod" -o jsonpath='{.spec.nodeName}')

# step 3: iterate trough the containers and create an array of container_ids
for container in $containers; do
	container_id=$(kubectl get pods -n $namespace $pod_name -o jsonpath='{.status.containerStatuses[?(@.name=="$container")].containerID}' | cut -d '/' -f 3)

# step 4: ssh onto the node
#
# step 5: for each container_id, find init.pid from /run/containerd/io.containerd.runtime.v2.task/k8s.io/<container_id>/init.pid and save this value to an array of init_pids
#
# step 6: iterate through the init_pids and find their PPID (should be the containerd process PID)
#
# step 7: now we can run some form of strace -fp <PPID> -o /var/syscall-$container_id.log (use sudo timeout 1h... to have it running for an extended period)
