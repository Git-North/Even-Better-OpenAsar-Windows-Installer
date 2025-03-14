@echo off
rem This changes variables from %variable% to !variable! to allow for delayed expansion
rem This is required for the for loops to work properly
setlocal enabledelayedexpansion

rem lil animation, can be skipped by pressing any key 3 times
call :displayText "."
cls
call :displayText "="
cls
call :displayText "#"


rem Check Discords
set /a DiscordMath=10
if exist "%localappdata%\Discord\" (set /a DiscordMath=%DiscordMath%*2)
if exist "%localappdata%\DiscordPTB\" (set /a DiscordMath=%DiscordMath%*3)
if exist "%localappdata%\DiscordCanary\" (set /a DiscordMath=%DiscordMath%*5)
if exist "%localappdata%\DiscordDevelopment\" (set /a DiscordMath=%DiscordMath%*7)

rem Discord flavor selection menu
echo.
echo [94mSelect Discord version:[0m
set /a "DM=%DiscordMath%/2"
if %DM:~-1% equ 0 (echo 1. Discord Stable (Default^)) else echo [2m[9m1. Discord Stable [29m (Not Installed)[0m  & set "DM=%DiscordMath%"
set /a "DM=%DiscordMath%/3"
if %DM:~-1% equ 0 (echo 2. Discord PTB) else echo [2m[9m2. Discord PTB [29m(Not Installed)[0m & set "DM=%DiscordMath%"
set /a "DM=%DiscordMath%/5"
if %DM:~-1% equ 0 (echo 3. Discord Canary) else echo [2m[9m3. Discord Canary [29m(Not Installed)[0m & set "DM=%DiscordMath%"
set /a "DM=%DiscordMath%/7"
if %DM:~-1% equ 0 (echo 4. Discord Development) else echo [2m[9m4. Discord Development [29m(Not Installed)[0m & set "DM=%DiscordMath%"
if %DiscordMath% equ 20 set "selection=1"
if %DiscordMath% equ 30 set "selection=2"
if %DiscordMath% equ 50 set "selection=3"
if %DiscordMath% equ 70 set "selection=4"
if not "%~1"=="" set "selection=%~1"
if "%selection%"=="" (echo a > NUL) else echo. & echo Only one Discord installation detected or a command line argument was passed & goto :selection
echo 0. [1mAll[0m
echo.
set /p "selection=Enter the number corresponding to your selection: "
echo.
:selection
if "%selection%"=="1" (
    set "discordApp=Discord"
) else if "%selection%"=="2" (
    set "discordApp=DiscordPTB"
) else if "%selection%"=="3" (
    set "discordApp=DiscordCanary"
) else if "%selection%"=="4" (
    set "discordApp=DiscordDevelopment"
) else if "%selection%"=="0" (
    start "" cmd /c %~0 1
    start "" cmd /c %~0 2
    start "" cmd /c %~0 3
    start "" cmd /c %~0 4
    
) else if "%selection%"=="" (
    echo No input detected. Defaulting to Discord Stable.
    set "discordApp=Discord"
) else (
	color 04
    echo Invalid selection. Please try again.
    color
    timeout /t 5
    exit /b
)


rem Finds the latest major, minor, and patch version numbers for the selected Discord flavor
set "latestMajor=0"
set "latestMinor=0"
set "latestPatch=0"

for /f "delims=" %%d in ('dir /b /ad /on "%localappdata%\%discordApp%\app-*"') do (
    set "folderName=%%~nxd"
    rem Split the version number into major, minor, and patch
    for /f "tokens=1-3 delims=.-" %%a in ("!folderName:~4!") do (
        set /a "major=%%a"
        set /a "minor=%%b"
        set /a "patch=%%c"
        rem Compare numerically
        if !major! gtr !latestMajor! (
            set "latestMajor=!major!"
            set "latestMinor=!minor!"
            set "latestPatch=!patch!"
        ) else if !major! equ !latestMajor! (
            if !minor! gtr !latestMinor! (
                set "latestMinor=!minor!"
                set "latestPatch=!patch!"
            ) else if !minor! equ !latestMinor! (
                if !patch! gtr !latestPatch! (
                    set "latestPatch=!patch!"
                )
            )
        )
    )
)

rem Construct the latest version string
set "latestVersion=!latestMajor!.!latestMinor!.!latestPatch!"

rem If no version folders are found, exit. We can't continue
if "!latestVersion!"=="0.0.0" (
    color 04
    echo No version folders found.
    color
    timeout /t 5
    exit /b
)

echo Closing Discord... (wait around 3 seconds)
echo.

rem Kills Discord multiple times to make sure it's closed
for /l %%i in (1,1,3) do (
    C:\Windows\System32\TASKKILL.exe /f /im %discordApp%.exe > nul 2> nul
)

rem Waits 3 seconds to make sure Discord is fully closed
C:\Windows\System32\TIMEOUT.exe /t 3 /nobreak > nul 2> nul
cls

rem Let the user make sure all info is correct before continuing
echo.
echo Installer updated by [34m@aaronliu[0m and [32m@GreenMan36[0, maintained by [95m@Git-North[0m
echo.
echo Confirm the following information before continuing.
echo.
echo Version: %discordApp%
echo App version: %latestVersion%
echo Full path: %localappdata%\%discordApp%\app-%latestVersion%\resources\
echo.
timeout /t 5

echo Installing OpenAsar... (ignore any flashes, this is a download progress bar)
echo.

echo 1. Backing up original app.asar to app.asar.backup
rem Popular client mods use these files as the asar to read discord from

set fileSizeLimit=1024

rem Check if _app.asar exists and its size is less than the limit (1024 KB)
for %%F in ("%localappdata%\%discordApp%\app-%latestVersion%\resources\_app.asar") do (
    set fileSize=%%~zF
    echo Checking _app.asar file size: !fileSize!
    if !fileSize! LSS %fileSizeLimit% (
        echo File is smaller than 1024 KB, deleting _app.asar instead of backing it up.
        del /f /q "%%F"
    ) else (
        echo Detected Vencord installation, installing to _app.asar instead.
        move /y "%%F" "%localappdata%\%discordApp%\app-%latestVersion%\resources\_app.asar.backup" >nul
    )
)

rem Check if app.orig.asar exists and its size is less than the limit (1024 KB)
for %%F in ("%localappdata%\%discordApp%\app-%latestVersion%\resources\app.orig.asar") do (
    set fileSize=%%~zF
    echo Checking app.orig.asar file size: !fileSize!
    if !fileSize! LSS %fileSizeLimit% (
        echo File is smaller than 1024 KB, deleting app.orig.asar instead of backing it up.
        del /f /q "%%F"
    ) else (
        echo Detected Replugged installation, installing to app.orig.asar instead.
        move /y "%%F" "%localappdata%\%discordApp%\app-%latestVersion%\resources\app.orig.asar.backup" >nul
    )
)

rem Final check for the default app.asar file
for %%F in ("%localappdata%\%discordApp%\app-%latestVersion%\resources\app.asar") do (
    set fileSize=%%~zF
    echo Checking app.asar file size: !fileSize!
    if !fileSize! LSS %fileSizeLimit% (
        echo File is smaller than 1024 KB, deleting app.asar instead of backing it up.
        del /f /q "%%F"
    ) else (
        echo No mod known, backing up app.asar.
        move /y "%%F" "%localappdata%\%discordApp%\app-%latestVersion%\resources\app.asar.backup" >nul
    )
)

timeout /t 5


rem If the copy command failed, exit
if errorlevel 1 (
    color 04
    echo Error: Failed to copy the file.
    echo Please check the file paths and try again.
    echo.
    color
    timeout /t 5
    exit
)

rem Download OpenAsar, change the color so the download bar blends in
color 36
echo 2. Downloading OpenAsar
if exist "%localappdata%\%discordApp%\app-%latestVersion%\resources\_app.asar.backup" (
    powershell -Command "Invoke-WebRequest https://github.com/GooseMod/OpenAsar/releases/download/nightly/app.asar -OutFile "%localappdata%\%discordApp%\app-%latestVersion%\resources\_app.asar"" >nul
) else ( if exist "%localappdata%\%discordApp%\app-%latestVersion%\resources\app.orig.asar.backup" (
    powershell -Command "Invoke-WebRequest https://github.com/GooseMod/OpenAsar/releases/download/nightly/app.asar -OutFile "%localappdata%\%discordApp%\app-%latestVersion%\resources\app.orig.asar"" >nul
) else (
    rem No mod known
    powershell -Command "Invoke-WebRequest https://github.com/GooseMod/OpenAsar/releases/download/nightly/app.asar -OutFile "%localappdata%\%discordApp%\app-%latestVersion%\resources\app.asar"" >nul
))

rem Check if the download command failed
if not %errorlevel%==0 (
    color 04
    echo Error: Failed to download and replace the asar file.
    echo Attempting to restore backup...
    move /y "%localappdata%\%discordApp%\app-%latestVersion%\resources\app.asar.backup" "%localappdata%\%discordApp%\app-%latestVersion%\resources\app.asar" >nul

    if not %errorlevel%==0 (
        echo Error: Failed to restore the backup. Check %localappdata%\%discordApp%\app-%latestVersion%\resources\ and make sure to restore the .backup file to .asar for Discord to be able to launch again.
        timeout /t 5
    ) else (
        echo Backup restored successfully. Discord was not modded but should be able to be launched.
    )
    exit
)

rem Change the color to indicate success and start Discord
cls
color 02
echo.
echo Opening Discord...
start "" "%localappdata%\%discordApp%\Update.exe" --processStart %discordApp%.exe > nul 2> nul

C:\Windows\System32\TIMEOUT.exe /t 1 /nobreak > nul 2> nul

echo.
echo.
echo OpenAsar should be installed! You can check by looking for an "OpenAsar" option in your Discord settings.
echo Not installed? Try restarting Discord, running the script again.
echo.


echo.
timeout /t 15
color

goto :eof

rem Subroutine to display text
:displayText
set "c=%~1"
echo.
echo Installer updated by [34m@aaronliu[0m and [32m@GreenMan36[0, maintained by [95m@Git-North[0m
echo.
echo !c!!c!!c!!c!  !c!!c!!c!  !c!!c!!c!!c! !c!   !c!      !c!!c!  !c!!c!!c!!c!  !c!!c!  !c!!c!!c!  
echo !c!  !c!  !c!  !c! !c!    !c!!c!  !c!     !c!  !c! !c!    !c!  !c! !c!  !c! 
echo !c!  !c!  !c!!c!!c!  !c!!c!!c!!c! !c! !c! !c!     !c!!c!!c!!c! !c!!c!!c!!c! !c!!c!!c!!c! !c!!c!!c!  
echo !c!  !c!  !c!    !c!    !c!  !c!!c!     !c!  !c!    !c! !c!  !c! !c!  !c! 
echo !c!!c!!c!!c!  !c!    !c!!c!!c!!c! !c!   !c!  !c!  !c!  !c! !c!!c!!c!!c! !c!  !c! !c!  !c! 
echo.
C:\Windows\System32\TIMEOUT.exe /t 1 > nul 2> nul

goto :eof

exit /b

