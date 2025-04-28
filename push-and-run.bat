@echo off
setlocal enabledelayedexpansion

REM Set your Docker Hub credentials and image name
set DOCKER_USERNAME=xamderbilla
set IMAGE_NAME=akshopping-frontend
set STACK_NAME=my-app

REM Build the image
echo Building Docker image...
docker build -t %DOCKER_USERNAME%/%IMAGE_NAME% ./client

REM Push the image to Docker Hub
echo Pushing image to Docker Hub...
docker push %DOCKER_USERNAME%/%IMAGE_NAME%

REM Check if stack exists and remove it if it does
echo Checking for existing stack...
docker stack ls | findstr %STACK_NAME% >nul
if %errorlevel% equ 0 (
    echo Removing existing stack %STACK_NAME%...
    docker stack rm %STACK_NAME%
    timeout /t 10 /nobreak >nul
)

REM Deploy the stack
echo Deploying stack %STACK_NAME%...
docker stack deploy -c docker-compose.yml %STACK_NAME%

echo Deployment completed!

