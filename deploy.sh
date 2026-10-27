#!/bin/bash

# 1. Configuration Variables
UNIQUE_SUFFIX="bettyngam123" # <-- CHANGE THIS to your initials or numbers
RESOURCE_GROUP="rg-sql-lab-prod"
PRIMARY_LOCATION="canadacentral"
SECONDARY_LOCATION="canadaeast"
PRIMARY_SERVER="sql-primary-srv-$UNIQUE_SUFFIX"
SECONDARY_SERVER="sql-secondary-srv-$UNIQUE_SUFFIX"
POOL_NAME="ep-hr-workloads-prod"
DB_1="db-hr-employees"
DB_2="db-hr-payrollss"
ADMIN_USER="sqladmin"
# Securely prompt for password (input is hidden while typing)
read -s -p "🔑 Enter a secure Azure SQL Admin Password: " ADMIN_PASSWORD
echo "" 

echo "🚀 Starting Automated Azure SQL Infrastructure Deployment..."

# 2. Create the Resource Group
az group create --name $RESOURCE_GROUP --location $PRIMARY_LOCATION

# 3. Create Primary SQL Server
echo "🏢 Creating Primary Server in $PRIMARY_LOCATION..."
az sql server create --name $PRIMARY_SERVER --resource-group $RESOURCE_GROUP \
  --location $PRIMARY_LOCATION --admin-user $ADMIN_USER --admin-password $ADMIN_PASSWORD

# 4. Configure Server Firewall Rules
echo "🧱 Configuring Firewall Rules..."
# Allow native Azure services to route internally
az sql server firewall-rule create --resource-group $RESOURCE_GROUP --server $PRIMARY_SERVER \
  --name AllowAzureServices --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0

# 5. Create the Elastic Performance Pool (Shared compute bucket)
echo "🛍️ Creating Elastic Pool..."
az sql elastic-pool create --resource-group $RESOURCE_GROUP --server $PRIMARY_SERVER \
  --name $POOL_NAME --edition Standard --capacity 50

# 6. Deploy Both Databases Inside the Shared Pool
echo "🗄️ Provisioning databases inside the Elastic Pool..."
az sql db create --resource-group $RESOURCE_GROUP --server $PRIMARY_SERVER --name $DB_1 --pool-name $POOL_NAME
az sql db create --resource-group $RESOURCE_GROUP --server $PRIMARY_SERVER --name $DB_2 --pool-name $POOL_NAME

# 7. Create Secondary Disaster Recovery Server
echo "🌍 Creating DR Standby Server in $SECONDARY_LOCATION..."
az sql server create --name $SECONDARY_SERVER --resource-group $RESOURCE_GROUP \
  --location $SECONDARY_LOCATION --admin-user $ADMIN_USER --admin-password $ADMIN_PASSWORD

# 8. Establish Asynchronous Geo-Replication Link for Database 2
echo "📡 Establishing Cross-Region Geo-Replication link..."
az sql db replica create --resource-group $RESOURCE_GROUP --server $PRIMARY_SERVER \
  --name $DB_2 --partner-server $SECONDARY_SERVER --partner-resource-group $RESOURCE_GROUP

echo "✅ Deployment finished successfully! Infrastructure pipeline is operational."
