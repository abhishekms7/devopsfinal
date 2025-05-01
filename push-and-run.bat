@echo off
REM Docker build and deployment script with port conflict resolution

SET DOCKER_USER=abhishekak71
SET IMAGE_NAME=akshopping-frontend
SET TAG=latest
SET DEFAULT_PORT=3000
SET ALTERNATE_PORT=3001

REM 1. Check if DEFAULT_PORT is available
netstat -ano | findstr :%DEFAULT_PORT% >nul
IF %ERRORLEVEL% EQU 0 (
    echo [WARNING] Port %DEFAULT_PORT% is in use. Using alternative port %ALTERNATE_PORT%.
    SET PORT=%ALTERNATE_PORT%
) ELSE (
    SET PORT=%DEFAULT_PORT%
)

REM 2. Build Docker image
echo [STEP 1/3] Building Docker image...
cd client
docker build -t %DOCKER_USER%/%IMAGE_NAME%:%TAG% .

IF %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Docker build failed
    exit /b 1
)

REM 3. Push to Docker Hub
echo [STEP 2/3] Pushing to Docker Hub...
docker push %DOCKER_USER%/%IMAGE_NAME%:%TAG%

IF %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Docker push failed
    exit /b 1
)

REM 4. Run container with dynamic port selection
echo [STEP 3/3] Starting container...
docker stop %IMAGE_NAME% 2>nul
docker rm %IMAGE_NAME% 2>nul
docker run -d --name %IMAGE_NAME% -p %PORT%:3000 %DOCKER_USER%/%IMAGE_NAME%:%TAG%

IF %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Container startup failed
    exit /b 1
)

echo [SUCCESS] Client deployed at http://localhost:%PORT%/
exit /b 0
