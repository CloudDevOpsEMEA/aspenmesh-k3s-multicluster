
# Kubernetes
export KUBECONFIG1=/home/ubuntu/.kube/cluster1-kubeconfig.yaml
export KUBECONFIG2=/home/ubuntu/.kube/cluster2-kubeconfig.yaml

source <(kubectl completion bash)

alias k1="kubectl --kubeconfig=${KUBECONFIG1} "
alias k2="kubectl --kubeconfig=${KUBECONFIG2} "
complete -F __start_kubectl k1
complete -F __start_kubectl k2

alias k9s1="k9s --kubeconfig=${KUBECONFIG1}"
alias k9s2="k9s --kubeconfig=${KUBECONFIG2}"
