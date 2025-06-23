# 🛠️ Ansible-Driven Configuration Inside Kubernetes Pods

This project demonstrates how to manually set up Ansible inside a Kubernetes pod (ansible-master) and use it to configure another pod (app-managed) using SSH with password-based authentication. In this example, we install and start NGINX on the managed pod via Ansible.

## 📦 Components

- `ansible-master`: Pod with Ansible installed (controller)
- `app-managed`: Pod running Ubuntu (target), accessed via SSH


## 🚀 Setup Instructions

### 1️⃣ Create the Pods

**ansible-master.yaml**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: ansible-master
spec:
  containers:
  - name: ansible
    image: your-dockerhub-username/ansible-ubuntu:manual
    ports:
    - containerPort: 22
````

**app-managed.yaml**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-managed
  labels:
    app: web
spec:
  containers:
  - name: app
    image: ubuntu:22.04
    command: ["sleep"]
    args: ["infinity"]
    ports:
    - containerPort: 22
```

### 2️⃣ Apply the Pods

```bash
kubectl apply -f ansible-master.yaml
kubectl apply -f app-managed.yaml
kubectl get pods -o wide
```


### 3️⃣ SSH Setup in `app-managed` Pod

```bash
kubectl exec -it app-managed -- bash

apt update
apt install -y openssh-server curl
mkdir /var/run/sshd
echo 'root:root' | chpasswd
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
/usr/sbin/sshd
```
> `mkdir /var/run/sshd ` The SSH daemon (sshd) uses /var/run/sshd to store its PID file and runtime data. If this directory doesn’t exist, sshd will fail to start with an error like: Missing privilege separation directory: /var/run/sshd

> `/usr/sbin/sshd` This starts the OpenSSH daemon — the service that listens for incoming SSH connections. To enable your container (e.g., app-managed) to accept SSH connections from your ansible-master pod.  If sshd is not running, Ansible can’t connect to the node because SSH port 22 is closed.

### 4️⃣ Configure Ansible in `ansible-master`

```bash
kubectl exec -it ansible-master -- bash

ansible --version   # Ensure Ansible is installed
```

**Create an inventory file**

```ini
[web]
<app-managed-IP> ansible_user=root ansible_password=root ansible_ssh_common_args='-o StrictHostKeyChecking=no'
```
> `'-o StrictHostKeyChecking=no'` This tells SSH not to prompt you to verify the host's authenticity when connecting for the first time.

**Create the playbook in ansible-master: `setup.yml`**

```yaml
- name: Install and start NGINX on web server
  hosts: web
  become: yes
  tasks:
    - name: Update apt cache
      apt:
        update_cache: yes

    - name: Install NGINX
      apt:
        name: nginx
        state: present

    - name: Start and enable NGINX
      service:
        name: nginx
        state: started
        enabled: yes
```



### 5️⃣ Run the Playbook

```bash
ansible-playbook -i inventory setup.yml
```
![image](https://github.com/user-attachments/assets/78e7858a-c7f7-4e86-96ce-0e9bd35ae148)




### 6️⃣ Verify NGINX Inside `app-managed`

```bash
kubectl exec -it app-managed -- bash
curl localhost
```
![image](https://github.com/user-attachments/assets/408bf783-c36d-43af-8763-02d6e9378f8b)


You should see the default NGINX welcome page HTML output.

## ✅ Outcome

* Manual Ansible setup inside a Kubernetes pod
* Remote configuration of another pod using SSH
* Verified NGINX installation using Ansible playbook
