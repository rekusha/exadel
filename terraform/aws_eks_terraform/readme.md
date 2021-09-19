$aws configure
AWS Access Key ID
AWS Secret Access Key

or
$export AWS_ACCESS_KEY_ID="lalala1"
$export AWS_SECRET_ACCESS_KEY="lalala2"

$terraform init
$terraform plan
$terraform apply

$terraform output

$aws eks --region eu-central-1 update-kubeconfig --name orekun_training-eks-XUgSB3G7(cluster name from output)

$kubectl get nodes
$kubectl get pods --all-namespaces
