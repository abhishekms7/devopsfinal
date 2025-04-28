@echo off

:: Build and push
docker build -t abhishekak71/akshopping-frontend .
docker push abhishekak71/akshopping-frontend

:: Stop and remove existing containers
docker-compose down || echo "No existing containers to remove"

:: Start new deployment
docker-compose up -d

:: Verify
timeout /t 5 /nobreak > nul
docker ps | find "akshopping-frontend"

if %errorlevel% == 0 (
    echo Deployment successful!
    exit 0
) else (
    echo Deployment failed!
    exit 1
)
