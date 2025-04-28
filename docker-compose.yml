@echo off
setlocal enabledelayedexpansion

REM Set your Docker Hub credentials and image name
set DOCKER_USERNAME=abhishekak71
set IMAGE_NAME=akshopping-frontend
set STACK_NAME=my-app
set NETWORK_NAME=%STACK_NAME%_app-network
set COMPOSE_FILE=docker-compose.yml

REM Build the image
echo Building Docker image...
docker build -t %DOCKER_USERNAME%/%IMAGE_NAME% ./client
if %errorlevel% neq 0 (
    echo ERROR: Docker build failed
    exit /b 1
)

REM Push the image to Docker Hub
echo Pushing image to Docker Hub...
docker push %DOCKER_USERNAME%/%IMAGE_NAME%
if %errorlevel% neq 0 (
    echo ERROR: Docker push failed
    exit /b 1
)

REM Check if stack exists and remove it if it does
echo Checking for existing stack...
docker stack ls | findstr %STACK_NAME% >nul
if %errorlevel% equ 0 (
    echo Removing existing stack %STACK_NAME%...
    docker stack rm %STACK_NAME%
    
    REM Wait for resources to be released
    echo Waiting for stack resources to be removed...
    timeout /t 15 /nobreak >nul
    
    REM Verify network is removed (Docker sometimes leaves networks)
    docker network inspect %NETWORK_NAME% >nul 2>&1
    if %errorlevel% equ 0 (
        echo Removing orphaned network %NETWORK_NAME%...
        docker network rm %NETWORK_NAME%
        timeout /t 5 /nobreak >nul
    )
)

REM Ensure the network exists before deployment
docker network inspect %NETWORK_NAME% >nul 2>&1
if %errorlevel% neq 0 (
    echo Creating network %NETWORK_NAME%...
    docker network create --driver overlay --attachable %NETWORK_NAME%
    if %errorlevel% neq 0 (
        echo ERROR: Failed to create network %NETWORK_NAME%
        exit /b 1
    )
)

REM Deploy the stack
echo Deploying stack %STACK_NAME%...
docker stack deploy -c %COMPOSE_FILE% %STACK_NAME%
if %errorlevel% neq 0 (
    echo ERROR: Stack deployment failed
    exit /b 1
)

REM Verify deployment
echo Verifying deployment...
timeout /t 10 /nobreak >nul

docker service ls --filter "name=%STACK_NAME%_web" | findstr "1/1" >nul
if %errorlevel% equ 0 (
    echo Deployment successful!
    exit /b 0
) else (
    echo ERROR: Service failed to start
    docker service ps %STACK_NAME%_web --no-trunc
    exit /b 1
)
