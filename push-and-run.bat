@echo off
set NETWORK_NAME=my-app_app-network

:: Step 1: Docker login
echo Logging into Docker...
echo **** | docker login -u abhishekak71 --password-stdin
if %errorlevel% neq 0 (
    echo ERROR: Docker login failed.
    exit /b 1
)

:: Step 2: Build and push Docker image
echo Building Docker image...
docker build -t abhishekak71/akshopping-frontend:latest .
if %errorlevel% neq 0 (
    echo ERROR: Docker build failed.
    exit /b 1
)

echo Pushing image to Docker Hub...
docker push abhishekak71/akshopping-frontend:latest
if %errorlevel% neq 0 (
    echo ERROR: Docker push failed.
    exit /b 1
)

:: Step 3: Check if the network exists, and create it if it doesn't
echo [3/4] Checking if the network %NETWORK_NAME% exists...
docker network inspect %NETWORK_NAME% >nul 2>&1
if %errorlevel% neq 0 (
    echo Network %NETWORK_NAME% does not exist. Creating it...
    docker network create --driver overlay --attachable %NETWORK_NAME%
    if %errorlevel% neq 0 (
        echo ERROR: Failed to create network %NETWORK_NAME%.
        exit /b 1
    )
) else (
    echo Network %NETWORK_NAME% already exists. Skipping creation.
)

:: Step 4: Deploy the stack
echo [4/4] Deploying stack my-app...
docker stack deploy -c docker-compose.yml my-app
if %errorlevel% neq 0 (
    echo ERROR: Stack deployment failed.
    exit /b 1
)

echo Deployment completed successfully!
