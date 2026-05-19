#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "======================================"
echo " Starting Azure Deployment Setup..."
echo "======================================"

# 1. Initialize and apply the first phase of Terraform (Create ACR)
echo "=> Initializing Terraform..."
cd terraform
terraform init

echo "=> Provisioning Azure Container Registry (ACR)..."
# We target only the resource group and ACR first so we can push images to it
terraform apply -target=azurerm_resource_group.rg -target=azurerm_container_registry.acr -auto-approve

# Extract the ACR login server and credentials from Terraform output
ACR_LOGIN_SERVER=$(terraform output -raw acr_login_server)
ACR_USERNAME=$(terraform output -raw acr_admin_username)
ACR_PASSWORD=$(terraform output -raw acr_admin_password)

echo "=> Logging into Azure Container Registry..."
echo $ACR_PASSWORD | sudo docker login $ACR_LOGIN_SERVER -u $ACR_USERNAME --password-stdin

cd ..

# 2. Build and push the Docker images
echo "=> Building and pushing the Backend image..."
sudo docker build -t $ACR_LOGIN_SERVER/backend:latest ./server
sudo docker push $ACR_LOGIN_SERVER/backend:latest

echo "=> Building and pushing the Frontend image..."
# Since the frontend needs to know the backend URL to make API calls, and we don't know the exact 
# Container App URL until it's deployed, a common pattern is to either:
# A) Predict the URL (ACA URLs are slightly randomized)
# B) Deploy the backend first, get the URL, then build the frontend, then deploy the frontend.
# Let's do B for accuracy!

cd terraform
echo "=> Provisioning Backend Container App to retrieve its URL..."
terraform apply -target=azurerm_log_analytics_workspace.law -target=azurerm_container_app_environment.env -target=azurerm_container_app.backend -auto-approve

BACKEND_URL=$(terraform output -raw backend_url)
echo "=> Backend deployed at: $BACKEND_URL"
cd ..

echo "=> Building Frontend image with VITE_APP_BASE_URL=$BACKEND_URL/api ..."
sudo docker build --build-arg VITE_APP_BASE_URL=$BACKEND_URL/api -t $ACR_LOGIN_SERVER/frontend:latest ./client
sudo docker push $ACR_LOGIN_SERVER/frontend:latest

# 3. Final Terraform Apply to deploy the frontend
cd terraform
echo "=> Provisioning Frontend Container App..."
terraform apply -auto-approve

FRONTEND_URL=$(terraform output -raw frontend_url)

echo "======================================"
echo " Deployment Complete! "
echo "======================================"
echo "Frontend is live at: $FRONTEND_URL"
echo "Backend is live at: $BACKEND_URL"
echo "======================================"
