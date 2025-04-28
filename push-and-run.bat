@echo off
setlocal enabledelayedexpansion

:: Configuration - ensure these match your environment
set DOCKER_USERNAME=abhishekak71
set IMAGE_NAME=akshopping-frontend
set STACK_NAME=my-app
set NETWORK_NAME=%STACK_NAME%_app-network
set COMPOSE_FILE=docker-compose.yml
set BUILD_CONTEXT=./client
set TAG=latest
set SERVICE_NAME=%STACK_NAME%_web

:: Set Docker CLI to non-interactive mode
set DOCKER_CLI_HINTS=false

:: Build phase
echo [1/4] Building Docker image...
docker build -t %DOCKER_USERNAME%/%IMAGE_NAME%:%TAG% %BUILD_CONTEXT%
if %errorlevel% neq 0 (
    echo ERROR: Docker build failed
    exit /b 1
)

:: Push phase
echo [2/4] Pushing image to Docker Hub...
docker push %DOCKER_USERNAME%/%IMAGE_NAME%:%TAG%
if %errorlevel% neq 0 (
    echo ERROR: Docker push failed
    exit /b 1
)

:: Check if overlay network exists
echo [3/4] Checking if the network %NETWORK_NAME% exists...
docker network ls | find /i "%NETWORK_NAME%" >nul
if %errorlevel% neq 0 (
    echo Network %NETWORK_NAME% does not exist. Creating it...
    docker network create --driver overlay --attachable %NETWORK_NAME%
    if %errorlevel% neq 0 (
        echo ERROR: Failed to create network %NETWORK_NAME%
        exit /b 1
    )
)

:: Stack removal phase
echo [4/4] Checking for existing stack...
docker stack ls | find /i "%STACK_NAME%" >nul
if %errorlevel% equ 0 (
    echo Removing existing stack %STACK_NAME%...
    docker stack rm %STACK_NAME%
    
    :: Extended wait time for Windows/Docker synchronization
    echo Waiting for resources to release (up to 60 seconds)...
    call :wait_for_network_removal %NETWORK_NAME% 60
)

:: Deployment phase
echo Deploying stack %STACK_NAME%...
docker stack deploy -c %COMPOSE_FILE% %STACK_NAME% --with-registry-auth
if %errorlevel% neq 0 (
    echo ERROR: Stack deployment failed
    exit /b 1
)

:: Extended verification period
echo Verifying deployment (up to 90 seconds)...
call :verify_service_ready %SERVICE_NAME% 90

echo SUCCESS: Deployment completed successfully.
exit /b 0

:: --- Functions ---
:wait_for_network_removal
setlocal
set network=%1
set timeout=%2
set counter=0

:removal_loop
docker network inspect %network% >nul 2>&1
if %errorlevel% neq 0 (
    endlocal
    exit /b 0
)

set /a counter+=1
if %counter% geq %timeout% (
    echo WARNING: Network %network% still exists after %timeout% seconds - forcing removal
    docker network rm %network% >nul 2>&1
    endlocal
    exit /b 0
)

timeout /t 1 /nobreak >nul
goto removal_loop

:verify_service_ready
setlocal
set service=%1
set timeout=%2
set counter=0

:health_check_loop
docker service inspect %service% --format "{{.UpdateStatus.State}}" | find /i "completed" >nul
if %errorlevel% equ 0 (
    docker service ps %service% --format "{{.CurrentState}}" | find /i "running" >nul
    if %errorlevel% equ 0 (
        echo Service %service% is fully deployed and healthy
        endlocal
        exit /b 0
    )
)

set /a counter+=1
if %counter% geq %timeout% (
    echo ERROR: Service %service% did not become ready after %timeout% seconds
    echo Current service state:
    docker service ps %service% --no-trunc
    endlocal
    exit /b 1
)

timeout /t 1 /nobreak >nul
goto health_check_loop
