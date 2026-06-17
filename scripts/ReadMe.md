# Installation Scripts

This directory contains automation scripts used to install and configure software for the Azure three-tier architecture project.

## Prerequisites

* Ubuntu Server virtual machines
* User account with `sudo` privileges
* Internet connectivity for package downloads

Before running any script, ensure the VM is updated:

```bash
sudo apt update
```

---

## Script Overview

| Script              | Target VM | Purpose                            |
| ------------------- | --------- | ---------------------------------- |
| `install-nginx.sh`  | Web VM    | Installs and configures NGINX      |
| `install-tomcat.sh` | App VM    | Installs OpenJDK and Apache Tomcat |
| `install-mysql.sh`  | DB VM     | Installs and starts MySQL Server   |

---

## 1. NGINX Installation

### Target

* VM: `vm-web`
* Subnet: `WebSubnet`

### Run

```bash
chmod +x install-nginx.sh
./install-nginx.sh
```

### Verify

```bash
systemctl status nginx
```

Expected output:

* Service status: `active (running)`

Open the following URL in your browser:

```text
http://<web-vm-public-ip>
```

You should see the default NGINX welcome page.

---

## 2. Tomcat Installation

### Target

* VM: `vm-app`
* Subnet: `AppSubnet`

### Run

```bash
chmod +x install-tomcat.sh
./install-tomcat.sh
```

### Verify

Check the service status:

```bash
systemctl status tomcat10
```

Verify Tomcat is listening on port 8080:

```bash
ss -tulnp | grep 8080
```

Expected output:

* Service status: `active (running)`
* Port `8080` is listening

Test locally:

```bash
curl http://localhost:8080
```

---

## 3. MySQL Installation

### Target

* VM: `vm-db`
* Subnet: `DBSubnet`

### Run

```bash
chmod +x install-mysql.sh
./install-mysql.sh
```

### Verify

```bash
systemctl status mysql
```

Expected output:

* Service status: `active (running)`

Confirm MySQL is listening on port 3306:

```bash
ss -tulnp | grep 3306
```

---

## Connectivity Validation

Run the following tests after all installations are complete.

### Web VM → App VM

```bash
nc -zv <app-vm-private-ip> 8080
```

Expected:

```text
Connection succeeded
```

### App VM → DB VM

```bash
nc -zv <db-vm-private-ip> 3306
```

Expected:

```text
Connection succeeded
```

### Web VM → DB VM

```bash
nc -zv <db-vm-private-ip> 3306
```

Expected:

```text
Connection timed out
```

This confirms that Network Security Groups are correctly blocking direct communication between the web and database tiers.

---

## SSH Access Workflow

Connect to the private virtual machines using SSH hopping:

```bash
ssh azureuser@<web-vm-public-ip>

ssh azureuser@<app-vm-private-ip>

ssh azureuser@<db-vm-private-ip>
```

---

## Notes

* Only the web VM has a public IP address.
* Application and database VMs use private IP addresses only.
* Administrative access is performed through the web VM.
* Network Security Groups enforce least-privilege access between tiers.
