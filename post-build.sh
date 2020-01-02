cat > /etc/kubernetes/cloud-config <<-EOF
[Global]
KubernetesClusterTag=my-cluster
KubernetesClusterID=my-cluster
EOF

cat > /etc/systemd/system/kubelet.service <<-EOF
[Unit]
Description=Kubernetes Kubelet
Documentation=https://github.com/kubernetes/kubernetes
After=docker.service
Requires=docker.service

[Service]
ExecStartPre=/sbin/iptables -P FORWARD ACCEPT
ExecStart=/usr/bin/kubelet --cloud-provider aws \
    --config /etc/kubernetes/kubelet/kubelet-config.json \
    --allow-privileged=true \
    --kubeconfig /var/lib/kubelet/kubeconfig \
    --container-runtime docker \
    --network-plugin cni $KUBELET_ARGS $KUBELET_EXTRA_ARGS \
        --cloud-config /etc/kubernetes/cloud-config

Restart=on-failure
RestartForceExitStatus=SIGPIPE
RestartSec=5
KillMode=process

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload


#clusterAdmin ....
aws configure --profile=clusterAdmin
export AWS_PROFILE=clusterAdmin
aws eks update-kubeconfig --name ananta-eks-cluster --region=us-east-1


curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.14.0/bin/linux/amd64/kubectl
cp kubectl /bin
chmod 755 /bin/kubectl

#### RBAC ---  Required to add node to the cluster.
cat > config-map-auth.yml <<-EOF
apiVersion: v1
data:
  mapRoles: |
    - groups:
      - system:bootstrappers
      - system:nodes
      rolearn: arn:aws:iam::737142638485:role/ananta-EKSWorkerNodeRole
      username: system:node:{{EC2PrivateDNSName}}

kind: ConfigMap
metadata:
  creationTimestamp: "2019-12-15T18:20:17Z"
  name: aws-auth
  namespace: kube-system
  resourceVersion: "2624"
  selfLink: /api/v1/namespaces/kube-system/configmaps/aws-auth
  uid: 8baab2ba-1f67-11ea-a0a8-0e3f075323d9
EOF

kubectl apply -f config-map-auth.yml


