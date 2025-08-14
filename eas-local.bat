@echo off
:: This batch script acts as a wrapper for running EAS Android builds inside a Docker container.
:: It automatically configures volume mounts for caches and the current working directory.

:: --- CONFIGURATION ---
SET IMAGE_NAME=eas-android-server:1.0

:: Set the names of your persistent Docker volumes for caches.
SET NPM_CACHE_VOL=npm-cache
SET YARN_CACHE_VOL=yarn-cache
SET EAS_CACHE_VOL=eas-cache
SET EXPO_CACHE_VOL=expo-cache
SET GRADLE_CACHE_VOL=gradle-cache

:: --- SCRIPT LOGIC ---
:: Use a local variable scope to avoid polluting the user's session.
SETLOCAL

:: Check for a local .env file.
IF EXIST "%cd%\.env" (
    ECHO Found .env file, passing it to the container...
    SET ENV_FILE_FLAG=--env-file "%cd%\.env"
) ELSE (
    SET ENV_FILE_FLAG=
)

:: Check if the EXPO_TOKEN environment variable is set on the host.
:: Only pass it to the container if it is defined.
IF DEFINED EXPO_TOKEN (
    SET EXPO_TOKEN_FLAG=-e EXPO_TOKEN
) ELSE (
    SET EXPO_TOKEN_FLAG=
)

:: Construct and execute the full docker run command.
:: The caret (^) symbol is used to continue the command on the next line.
ECHO Starting container %IMAGE_NAME%...
docker run ^
    --rm -it ^
    %ENV_FILE_FLAG% ^
    %EXPO_TOKEN_FLAG% ^
    -v "%NPM_CACHE_VOL%:/root/.npm" ^
    -v "%YARN_CACHE_VOL%:/root/.cache/yarn" ^
    -v "%EAS_CACHE_VOL%:/root/.eas" ^
    -v "%EXPO_CACHE_VOL%:/root/.expo" ^
    -v "%GRADLE_CACHE_VOL%:/root/.gradle" ^
    -v "%cd%:/workspace" ^
    -w /workspace ^
    %IMAGE_NAME% ^
    eas %*

:: End the local variable scope.
ENDLOCAL
