# Azure Three-Tier Architecture - Detailed Documentation

## 1. Project Objective

Design and deploy a secure three-tier application architecture on Microsoft Azure.

Goals:

* Separate web, application, and database layers.
* Restrict direct access to private servers.
* Control east-west traffic using Network Security Groups (NSGs).
* Implement secure administrative access through a jump host.
* Block direct communication from the web tier to the database tier.

---

## 2. Architecture Overview

### Components

| Layer            | VM     | Software      |
| ---------------- | ------ | ------------- |
| Web Tier         | vm-web | NGINX         |
| Application Tier | vm-app | Apache Tomcat |
| Database Tier    | vm-db  | MySQL         |

### Network Flow

```text id="17gwd5"
Internet
   │
   ▼
vm-web (Public IP)
   │
   ▼
vm-app (Private IP)
   │
   ▼
vm-db (Private IP)
```

---

## 3. Azure Resources

### Resource Group

| Property | Value         |
| -------- | ------------- |
| Name     | rg-three-tier |
| Region   | <your-region> |

### Virtual Network

| Property      | Value           |
| ------------- | --------------- |
| Name          | vnet-three-tier |
| Address Space | 10.0.0.0/16     |

### Subnets

| Subnet    | Address Range |
| --------- | ------------- |
| WebSubnet | 10.0.1.0/24   |
| AppSubnet | 10.0.2.0/24   |
| DBSubnet  | 10.0.3.0/24   |

---

## 4. Virtual Machines

### VM1 - Web Server

| Property  | Value     |
| --------- | --------- |
| Name      | vm-web    |
| Subnet    | WebSubnet |
| Public IP | Yes       |
| Software  | NGINX     |

Allowed inbound ports:

* TCP 22
* TCP 80

---

### VM2 - Application Server

| Property  | Value         |
| --------- | ------------- |
| Name      | vm-app        |
| Subnet    | AppSubnet     |
| Public IP | No            |
| Software  | Apache Tomcat |

Allowed inbound ports:

* TCP 22 from WebSubnet
* TCP 8080 from WebSubnet

---

### VM3 - Database Server

| Property  | Value    |
| --------- | -------- |
| Name      | vm-db    |
| Subnet    | DBSubnet |
| Public IP | No       |
| Software  | MySQL    |

Allowed inbound ports:

* TCP 22 from AppSubnet
* TCP 3306 from AppSubnet

---

## 5. Administrative Access

Direct SSH access is enabled only for the web server.

SSH workflow:

```bash id="a5eajg"
ssh azureuser@<web-vm-public-ip>

ssh azureuser@<app-vm-private-ip>

ssh azureuser@<db-vm-private-ip>
```

This approach follows the jump-host architecture pattern.

---

## 6. Software Installation

### Install NGINX

```bash id="kp1zh2"
sudo apt update
sudo apt install nginx -y
```

Verify:

```bash id="yx9l8d"
systemctl status nginx
```

---

### Install Tomcat

```bash id="6mqupk"
sudo apt update
sudo apt install openjdk-17-jdk -y
```

Install and configure Apache Tomcat.

Verify:

```bash id="f86y1l"
curl http://localhost:8080
```

---

### Install MySQL

```bash id="qg1h94"
sudo apt update
sudo apt install mysql-server -y
```

Verify:

```bash id="mubk54"
systemctl status mysql
```

---

## 7. Network Security Groups

### WebSubnet NSG

Allow:

* Internet → TCP 22
* Internet → TCP 80

---

### AppSubnet NSG

Allow:

* WebSubnet → TCP 22
* WebSubnet → TCP 8080

---

### DBSubnet NSG

Allow:

* AppSubnet → TCP 22
* AppSubnet → TCP 3306

Deny:

* WebSubnet → Any

Priority:

| Priority | Source    | Destination | Action |
| -------- | --------- | ----------- | ------ |
| 100      | WebSubnet | DBSubnet    | Deny   |

---

## 8. Connectivity Validation

### Successful Tests

Web → App:

```bash id="1vbnc9"
nc -zv <app-vm-private-ip> 8080
```

App → DB:

```bash id="5j7m7l"
nc -zv <db-vm-private-ip> 3306
```

Web → App SSH:

```bash id="7sjx6z"
nc -zv <app-vm-private-ip> 22
```

App → DB SSH:

```bash id="5iqjlc"
nc -zv <db-vm-private-ip> 22
```

---

### Blocked Tests

Web → DB:

```bash id="8lxh0s"
nc -zv <db-vm-private-ip> 3306
```

Expected result:

```text id="tpf9g4"
Connection timed out
```

Web → DB SSH:

```bash id="m6jjxv"
nc -zv <db-vm-private-ip> 22
```

Expected result:

```text id="g6ibdl"
Connection timed out
```

---

## 9. Security Considerations

* Only the web server has a public IP address.
* Application and database servers use private IP addresses.
* SSH access is restricted using NSGs.
* Direct communication between the web and database tiers is blocked.
* Administrative access is performed through a jump host.
* Least-privilege network access is enforced.

---

## 10. Future Improvements

* Automate deployment using Terraform.
* Replace jump host with Azure Bastion.
* Configure NGINX as a reverse proxy for Tomcat.
* Integrate Tomcat with MySQL.
* Enable Azure Monitor and Log Analytics.
* Store secrets in Azure Key Vault.
