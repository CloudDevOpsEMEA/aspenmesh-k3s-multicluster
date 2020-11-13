# Kubernetes
export KUBECONFIG=/home/ubuntu/.kube/config
source <(kubectl completion bash)

alias k1="kubectl --context=k1 "
alias k2="kubectl --context=k2 "
complete -F __start_kubectl k1
complete -F __start_kubectl k2

alias k9s1="k9s --context=k1"
alias k9s2="k9s --context=k2"
