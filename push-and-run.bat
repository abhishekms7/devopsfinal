@echo off

:: Build Docker image
echo Building Docker image...
docker build -t abhishekak71/akshopping-frontend .

:: Push image to Docker Hub
echo Pushing image to Docker Hub...
docker push abhishekak71/akshopping-frontend

:: Deploy stack
echo Checking for existing stack...

:: Check if network exists, create if it doesn't
docker network inspect my-app_app-network >nul 2>&1
if %errorlevel% neq 0 (
    echo Creating network my-app_app-network...
    docker network create my-app_app-network
) else (
    echo Network my-app_app-network already exists, skipping creation...
)

echo Deploying stack my-app...
docker stack deploy -c docker-compose.yml my-app

echo Deployment completed successfully
exit /b 0
