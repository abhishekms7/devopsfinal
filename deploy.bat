@echo off
setlocal EnableDelayedExpansion

REM Variables
set COMPOSE_FILE=docker-compose.yml

REM Function to clean up existing containers and services
echo Stopping and removing existing containers and services...

REM Bring down the existing setup
docker-compose -f "%COMPOSE_FILE%" down

REM Main deployment process
echo Starting deployment process...

REM Bring up the new setup
docker-compose -f "%COMPOSE_FILE%" up -d

echo Deployment completed successfully!
