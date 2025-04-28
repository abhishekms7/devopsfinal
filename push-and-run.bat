@echo off

:: Ensure Dockerfile is in the correct directory
echo Building Docker image...
docker build -t abhishekak71/akshopping-frontend .

:: Push image to Docker Hub
echo Pushing image to Docker Hub...
docker push abhishekak71/akshopping-frontend

:: Check for existing stack and network
echo Checking for existing stack...

:: Check if network exists, create if it doesn't
docker network inspect my-app_app-network >nul 2>&1
if %errorlevel% neq 0 (
    echo Creating network my-app_app-network...
    docker network create my-app_app-network
) else (
    echo Network my-app_app-network already exists, skipping creation...
)

:: Ensure docker-compose.yml is present in the current directory
if not exist "docker-compose.yml" (
    echo Error: docker-compose.yml not found in the current directory.
    exit /b 1
)

:: Deploy stack using docker-compose.yml
echo Deploying stack my-app...
docker stack deploy -c docker-compose.yml my-app

echo Deployment completed successfully
exit /b 0
