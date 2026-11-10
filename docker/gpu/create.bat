@echo off
setlocal EnableExtensions
cd /d "%~dp0"

set "COMPOSE_FILE=compose.yml"
set "ENV_FILE=.env"
set "CT=open-llama-gpu"
set "IMAGE=open-llama:gpu-latest"
if not defined INSTANCE_ENV set "INSTANCE_ENV=instance.env"
if not defined FORCE set "FORCE=0"

where docker >nul 2>&1
if errorlevel 1 goto :no_docker
if not exist "%COMPOSE_FILE%" goto :miss_compose
if not exist "%ENV_FILE%" goto :miss_env

set "POOL_IN=%POOL%"
set "WORKER_IN=%WORKER%"
set "POOL2_IN=%POOL2%"
set "GPU_COIN_IN=%GPU_COIN%"
set "START_IN=%START%"
set "GPU_VISIBLE_IN=%GPU_VISIBLE%"
set "GPU_API_PORT_IN=%GPU_API_PORT%"
set "GPU_DEVICES_IN=%GPU_DEVICES%"

for /f "usebackq tokens=1,* delims==" %%A in ("%ENV_FILE%") do set "%%A=%%B"

if exist "%INSTANCE_ENV%" for /f "usebackq tokens=1,* delims==" %%A in ("%INSTANCE_ENV%") do set "%%A=%%B"

if defined POOL_IN set "POOL=%POOL_IN%"
if defined WORKER_IN set "WORKER=%WORKER_IN%"
if defined POOL2_IN set "POOL2=%POOL2_IN%"
if defined GPU_COIN_IN set "GPU_COIN=%GPU_COIN_IN%"
if defined START_IN set "START=%START_IN%"
if defined GPU_VISIBLE_IN set "GPU_VISIBLE=%GPU_VISIBLE_IN%"
if defined GPU_API_PORT_IN set "GPU_API_PORT=%GPU_API_PORT_IN%"
if defined GPU_DEVICES_IN set "GPU_DEVICES=%GPU_DEVICES_IN%"

if "%~2"=="" goto :no_cli
set "POOL=%~1"
set "WORKER=%~2"
if not "%~3"=="" set "POOL2=%~3"
:no_cli

if not defined POOL goto :miss_pool
if not defined WORKER goto :miss_worker
if not defined GPU_COIN goto :miss_coin
if not defined START set "START=0"

docker image inspect "%IMAGE%" >nul 2>&1
if errorlevel 1 goto :miss_image

set "RUNNING=false"
for /f "delims=" %%R in ('docker inspect -f "{{.State.Running}}" "%CT%" 2^>nul') do set "RUNNING=%%R"
if "%RUNNING%"=="true" if not "%FORCE%"=="1" goto :busy

docker stop -t 10 "%CT%" >nul 2>&1
docker rm -f "%CT%" >nul 2>&1

echo create %CT%
docker compose --env-file "%ENV_FILE%" -f "%COMPOSE_FILE%" create --no-build
if errorlevel 1 goto :fail

docker inspect -f "{{range .Config.Env}}{{println .}}{{end}}" "%CT%" 2>nul | findstr /b /c:"POOL=" >nul
if errorlevel 1 goto :env_miss
docker inspect -f "{{range .Config.Env}}{{println .}}{{end}}" "%CT%" 2>nul | findstr /b /c:"WORKER=" >nul
if errorlevel 1 goto :env_miss
docker inspect -f "{{range .Config.Env}}{{println .}}{{end}}" "%CT%" 2>nul | findstr /b /c:"COIN=" >nul
if errorlevel 1 goto :env_miss
echo env ok: %CT%

if not "%START%"=="1" goto :done
echo start %CT%
docker start "%CT%" >nul
if errorlevel 1 goto :fail
set "H=none"
for /f "delims=" %%H in ('docker inspect -f "{{.State.Health.Status}}" "%CT%" 2^>nul') do set "H=%%H"
echo health: %H%

:done
echo done
exit /b 0

:no_docker
echo ERROR: docker not found
exit /b 1
:miss_compose
echo ERROR: missing %COMPOSE_FILE%
exit /b 1
:miss_env
echo ERROR: missing %ENV_FILE%
exit /b 1
:miss_pool
echo ERROR: POOL required
exit /b 1
:miss_worker
echo ERROR: WORKER required
exit /b 1
:miss_coin
echo ERROR: GPU_COIN required
exit /b 1
:miss_image
echo ERROR: missing image %IMAGE%
exit /b 1
:busy
echo ERROR: %CT% is running, use FORCE=1
exit /b 1
:env_miss
echo ERROR: env missing in %CT%
exit /b 1
:fail
echo ERROR: command failed
exit /b 1
