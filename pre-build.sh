yum update -y
yum install git jq unzip python2 iptables -y
ln -s /bin/python2 /bin/python
curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
unzip awscli-bundle.zip
./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
export PATH=$PATH:/usr/local/bin
cd /home/ec2-user
git clone https://github.com/awslabs/amazon-eks-ami.git

export TEMPLATE_DIR=/tmp/worker
mkdir -p $TEMPLATE_DIR
cd amazon-eks-ami
cp -r ./files/* $TEMPLATE_DIR

yum -y install epel-release
yum -y install jq

cat >/etc/yum.repos.d/docker.repo <<-EOF
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/7/
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF

yum -y install docker-engine
systemctl enable docker
systemctl start docker
systemctl status docker
systemctl restart docker


