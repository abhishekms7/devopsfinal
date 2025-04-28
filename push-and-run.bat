@echo off
setlocal

echo [1/4] Building Docker image...
docker build -t abhishekak71/akshopping-frontend:latest .

echo [2/4] Pushing image to Docker Hub...
docker push abhishekak71/akshopping-frontend:latest

echo [3/4] Checking for existing stack...

REM Remove existing stack if exists
docker stack rm my-app

REM Wait until the old network is removed properly
timeout /t 10 /nobreak

REM Force remove leftover network manually if it still exists
docker network inspect my-app_app-network >nul 2>&1
if %errorlevel%==0 (
    echo Found old network. Removing...
    docker network rm my-app_app-network
)

REM Wait a bit before deploying
timeout /t 5 /nobreak

echo [4/4] Deploying stack my-app...

docker stack deploy -c docker-compose.yml my-app

endlocal
