# High-Availability & Cost-Optimized Azure SQL Architecture (IaC)

## 📌 Project Overview
This repository contains automated infrastructure scripts to deploy an enterprise-grade cloud database topology using the Azure CLI. The architecture isolates workloads within a cost-efficient Elastic Pool and ensures disaster recovery capability via cross-region Asynchronous Geo-Replication.

## 📁 Repository Structure
- `deploy.sh`: Shell script orchestrating the full automated deployment.
- `README.md`: Architectural documentation and business impact summary.

## 🛠️ How to Deploy via Azure CLI
1. Log into your Azure environment: `az login`
2. Make the script executable: `chmod +x deploy.sh`
3. Run the script: `./deploy.sh`
