@echo off
REM push-and-run.bat - Docker build, push and run script for Jenkins

REM Set variables
SET DOCKER_USER=abhishekak71
SET IMAGE_NAME=devopsfinal
SET TAG=latest
SET PORT=3000

REM Build Docker image
echo [INFO] Building Docker image...
docker build -t %DOCKER_USER%/%IMAGE_NAME%:%TAG% .

IF %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Docker build failed
    exit /b 1
)

REM Push to Docker Hub
echo [INFO] Pushing image to Docker Hub...
docker push %DOCKER_USER%/%IMAGE_NAME%:%TAG%

IF %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Docker push failed
    exit /b 1
)

REM Stop and remove any existing container
echo [INFO] Stopping and removing existing containers...
docker stop %IMAGE_NAME% 2>nul || echo [INFO] No running containers found
docker rm %IMAGE_NAME% 2>nul || echo [INFO] No containers to remove

REM Run new container
echo [INFO] Running new container...
docker run -d --name %IMAGE_NAME% -p %PORT%:%PORT% %DOCKER_USER%/%IMAGE_NAME%:%TAG%

IF %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Docker run failed
    exit /b 1
)

echo [SUCCESS] Deployment completed successfully!
exit /b 0