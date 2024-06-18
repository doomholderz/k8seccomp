# step 1: take profile as argument
custom_profile_location="$1"

# step 2: get nodes running in the cluster as an array of node names
nodes=$(kubectl get nodes -o jsonpath='{.items[*].metadata.name}')

# step 3: find a candidate node (one which has capacity for more pods to be scheduled on it)
candidate_node=""

for node in $nodes; do
	capacity=$(kubectl get node "$node" -o jsonpath='{.status.capacity.pods}')
	current=$(kubectl describe node "$node" | grep "Non-terminated Pods:" | awk '{print $3}' | tr -d '()'
	if [ "$current" -lt "$capacity"  ]; then
		candidate_node="$node"
		break
	fi
done

# step 4: copy our custom seccomp profile to the expected directory in the canaidate node (this is where Kubernetes should look for custom localhost-defined seccomp profiles)
custom_profile_file=$(basename "$custom_profile_location")
custom_profile_name=$(custom_profile_file%.*)

scp "$custom_profile_location" "$SSH_USER@$candidate_node:/tmp/$custom_profile_file"
ssh "$SSH_USR@candidate_node" "sudo mv /tmp/$custom_profile_file /var/lib/kubelet/seccomp/$custom_profile_file"

# step 5: label candidate node with custom seccomp-custom=true

kubectl label nodes "$candidate_node" "seccomp-custom-$custom_profile_name=true"

# step 5: create pod with nodeselector configured for candidate node label, and localhost profile referencing the newly added <custom_profile.json>

pod_name="seccomp-custom-pod-$custom_profile_name"
node_selector_label="seccomp-custom-$custom_profile_name"
container_name="seccomp-test-$custom_profile_name"

cat <<EOF > "${pod_name}.yaml"
apiVersion: v1
kind: Pod
metadata:
  name: $pod_name
spec:
  nodeSelector:
    $node_selector_label: "true"
  containers:
  - name: $container_name
    image: nginx:latest  # Replace with your desired container image
    securityContext:
      seccompProfile:
        type: Localhost
        localhostProfile: $custom_profile_file
EOF

# step 6: deploy the pod in the cluster

kubectl apply -f "$pod_name.yaml"

# next steps will be to have the teardown of this (removing the file from the node, removing the manifest from your host, unlabelling the candidate node, stopping the pod)
# maybe this could be a process that runs in the background and waits for you to interact with it again to tell it to delete the resources created, so you can run this in one terminal tab and do your tests in another tab?
