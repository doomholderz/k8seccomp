# kube-profile-deployer
CLI tool for deploying custom AppArmor and seccomp profiles in Kubernetes clusters

Needs 3 commands:
- verify: 
    - validate the format of seccomp and AppArmor profiles to ensure they will run as expected 
    - in the future also alert on conflicts between profiles, and analyse the change with the currently used cluster profiles
- deploy-profile: 
    - checks for existing custom resource definitions of SeccompProfile and ApparmorProfile in cluster
    - if not present then create these using templated definitions
    - creates custom resource instances for each new profile created, using templated instances for each
    - creates DaemonSet to copy profiles to cluster Nodes' local filesystem
- apply-profile: 
    - annotate the specified namespace (e.g. production) with profile name(s) 
    - new pods within this namespace will inherit specified seccomp and AppArmor profiles by default 

To install:
- git clone repo
- cp validate_apparmor_profile.sh ~/bin/validate_apparmor_profile
- chmod +x "~/bin/validate_apparmor_profile"
- validate_apparmor_profile [file]
