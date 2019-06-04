from jenkins/jenkins
user root
run apt update
run apt install systemd -y
run RELEASE="$(curl -sSL https://dl.k8s.io/release/stable.txt)"
run mkdir -p /opt/bin
run cd /opt/bin
run curl -L --remote-name-all https://storage.googleapis.com/kubernetes-release/release/${RELEASE}/bin/linux/amd64/{kubeadm,kubelet,kubectl}
run curl -sSL "https://raw.githubusercontent.com/kubernetes/kubernetes/${RELEASE}/build/debs/kubelet.service" | sed "s:/usr/bin:/opt/bin:g" > /etc/systemd/system/kubelet.service
run mkdir -p /etc/systemd/system/kubelet.service.d
run curl -sSL "https://raw.githubusercontent.com/kubernetes/kubernetes/${RELEASE}/build/debs/10-kubeadm.conf" | sed "s:/usr/bin:/opt/bin:g" > /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
run systemctl enable --now kubelet
run apt install -y ebtables socat
run curl https://get.docker.com | bash
run PATH=$PATH:/opt/bin:/opt/cni/bin
run kubeadm init --pod-network-cidr=192.168.0.0/16
run export KUBECONFIG=/etc/kubernetes/admin.conf
run kubectl apply -f https://docs.projectcalico.org/v3.3/getting-started/kubernetes/installation/hosted/rbac-kdd.yaml
run kubectl apply -f https://docs.projectcalico.org/v3.3/getting-started/kubernetes/installation/hosted/kubernetes-datastore/calico-networking/1.7/calico.yaml
run kubectl taint nodes --all node-role.kubernetes.io/master-
run sudo mkdir ~/.kube
run sudo cp /etc/kubernetes/admin.conf ~/.kube/config
run sudo chown ${USER}:${USER} ~/.kube/config
run echo 'PATH=$PATH:/opt/bin:/opt/cni/bin' >> ~/.bashrc
run usermod -aG docker ${USER}
