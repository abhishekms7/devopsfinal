@echo off
setlocal enabledelayedexpansion

REM Set your Docker Hub credentials and image name
set DOCKER_USERNAME=abhishekak71
set IMAGE_NAME=akshopping-frontend
set STACK_NAME=my-app

REM Build the image
echo Building Docker image...
docker build -t %DOCKER_USERNAME%/%IMAGE_NAME% ./client
if %errorlevel% neq 0 (
    echo Error: Docker build failed!
    exit /b 1
)

REM Push the image to Docker Hub
echo Pushing image to Docker Hub...
docker push %DOCKER_USERNAME%/%IMAGE_NAME%
if %errorlevel% neq 0 (
    echo Error: Docker push failed!
    exit /b 1
)

REM Check if stack exists and remove it if it does
echo Checking for existing stack...
docker stack ls | findstr %STACK_NAME% >nul
if %errorlevel% equ 0 (
    echo Removing existing stack %STACK_NAME%...
    docker stack rm %STACK_NAME%
    echo Waiting for stack removal to complete...
    timeout /t 15 /nobreak >nul
)

REM Deploy the stack (ignore "network already exists" error)
echo Deploying stack %STACK_NAME%...
docker stack deploy -c docker-compose.yml %STACK_NAME% 2>&1 | findstr /v "already exists" >nul || (
    echo Warning: Network already exists (ignored)
)

REM Verify deployment
echo Verifying deployment...
docker service ls --filter "name=%STACK_NAME%_" --format "table {{.Name}}\t{{.Replicas}}"
if %errorlevel% neq 0 (
    echo Error: Stack deployment failed!
    exit /b 1
)

echo Deployment completed successfully!
exit /b 0
