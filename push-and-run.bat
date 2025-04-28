@echo off
setlocal enabledelayedexpansion

:: Configuration
set DOCKER_USERNAME=abhishekak71
set IMAGE_NAME=akshopping-frontend
set STACK_NAME=my-app
set NETWORK_NAME=%STACK_NAME%_app-network
set COMPOSE_FILE=docker-compose.yml
set BUILD_CONTEXT=./client
set TAG=latest

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

:: Stack removal phase
echo [3/4] Checking for existing stack...
docker stack ls | findstr %STACK_NAME% >nul
if %errorlevel% equ 0 (
    echo Removing existing stack %STACK_NAME%...
    docker stack rm %STACK_NAME%
    
    :: Wait for clean removal
    echo Waiting for resources to release...
    call :wait_for_network_removal %NETWORK_NAME% 20
)

:: Deployment phase
echo [4/4] Deploying stack %STACK_NAME%...
docker stack deploy -c %COMPOSE_FILE% %STACK_NAME%
if %errorlevel% neq 0 (
    echo ERROR: Stack deployment failed
    exit /b 1
)

:: Verification
echo Verifying deployment...
call :verify_service_health %STACK_NAME%_web 30

echo SUCCESS: Deployment completed
exit /b 0

:: Functions
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
    echo WARNING: Network %network% still exists after %timeout% seconds
    endlocal
    exit /b 1
)

timeout /t 1 /nobreak >nul
goto removal_loop

:verify_service_health
setlocal
set service=%1
set timeout=%2
set counter=0

:health_check_loop
docker service ps %service% --format "{{.CurrentState}}" | findstr "Running" >nul
if %errorlevel% equ 0 (
    docker service inspect %service% --format "{{.UpdateStatus.State}}" | findstr "completed" >nul
    if %errorlevel% equ 0 (
        endlocal
        exit /b 0
    )
)

set /a counter+=1
if %counter% geq %timeout% (
    echo ERROR: Service %service% not healthy after %timeout% seconds
    docker service ps %service% --no-trunc
    endlocal
    exit /b 1
)

timeout /t 1 /nobreak >nul
goto health_check_loop
