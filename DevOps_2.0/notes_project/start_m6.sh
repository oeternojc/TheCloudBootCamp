# (1) Step cluster creation
eksctl create cluster  --name humamgov-cluster --region us-east-1 --nodegroup-name standard-workers --node-type t3.medium --spot --nodes 3

2
aws eks update-kubeconfig --name humamgov-cluster


3
kubectl get svc
kubectl get nodes

4
eksctl utils associate-iam-oidc-provider --cluster humamgov-cluster --approve


5
eksctl create iamserviceaccount \
  --cluster=humamgov-cluster \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --role-name AmazonEKSLoadBalancerControllerRole \
  --attach-policy-arn=arn:aws:iam::542450504390:policy/AWSLoadBalancerControllerIAMPolicy \
  --approve

6
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=humamgov-cluster \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller


7
kubectl get deployment -n kube-system aws-load-balancer-controller


8
eksctl create iamserviceaccount \
  --cluster=humamgov-cluster \
  --name=humangov-pod-execution-role \
  --role-name HumanGovPodExecutionRole \
  --attach-policy-arn=arn:aws:iam::aws:policy/AmazonS3FullAccess \
  --attach-policy-arn=arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess \
  --region us-east-1 \
  --approve

  