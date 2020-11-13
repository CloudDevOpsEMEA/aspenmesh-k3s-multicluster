# Kubernetes
export KUBECONFIG=/home/ubuntu/.kube/config
source <(kubectl completion bash)
alias k=kubectl
complete -F __start_kubectl k
