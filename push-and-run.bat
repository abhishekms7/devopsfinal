@echo off
REM Docker build and deployment script for client project

SET DOCKER_USER=abhishekak71
SET IMAGE_NAME=devopsfinal-client
SET TAG=latest
SET PORT=3000

REM 1. Build Docker image from client directory
echo [STEP 1/3] Building Docker image...
cd client
docker build -t %DOCKER_USER%/%IMAGE_NAME%:%TAG% .

IF %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Docker build failed
    exit /b 1
)

REM 2. Push to Docker Hub
echo [STEP 2/3] Pushing to Docker Hub...
docker push %DOCKER_USER%/%IMAGE_NAME%:%TAG%

IF %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Docker push failed
    exit /b 1
)

REM 3. Run container
echo [STEP 3/3] Starting container...
docker stop %IMAGE_NAME% 2>nul
docker rm %IMAGE_NAME% 2>nul
docker run -d --name %IMAGE_NAME% -p %PORT%:%PORT% %DOCKER_USER%/%IMAGE_NAME%:%TAG%

IF %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Container startup failed
    exit /b 1
)

echo [SUCCESS] Client deployed at http://localhost:%PORT%/
exit /b 0
