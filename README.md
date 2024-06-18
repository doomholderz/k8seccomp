# kube-profile-deployer

### seccomp_profile_tester
Usage: 
+ Use from a Bastion/Jump host that has SSH access to your Kubernetes Nodes
+ chmod +x seccomp_profile_tester.sh
+ ./seccomp_profile_tester path/to/custom/seccomp/profile.json 

This will:
+ Find a candidate Node in your K8s cluster (not at Pod capacity)
+ Copy your custom seccomp profile onto /var/lib/kubelet/seccomp/<custom>.json
+ Label candidate Node with `seccomp-custom-<profile_name>`
+ Deploy a Pod onto the candidate Node, using the Node-stored custom seccomp profile 

