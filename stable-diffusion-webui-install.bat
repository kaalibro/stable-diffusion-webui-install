@echo off
setlocal EnableDelayedExpansion
title (Re)install Stable Diffusion web UI
cls

@REM Check if Git and Python are installed.
set GIT_URL=https://git-scm.com/downloads
set PYTHON_URL=https://www.python.org/downloads/release/python-3106/

where git >nul 2>nul || (
  echo [91mGit is not installed.[0m
  echo Please download and install the latest version of Git from [93m%GIT_URL%[0m and try again.
  echo.
  pause
  exit /b 1
)

where python >nul 2>nul || (
  echo [91mPython is not installed.[0m
  echo Please download and install Python 3.10.6 from [93m%PYTHON_URL%[0m and try again.
  echo.
  pause
  exit /b 1
)

echo [93mษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป[0m
echo [93mบ                          === READ FIRST: ===                          บ[0m
echo [93mบ[0m [96mCLEAN INSTALL:[0m[93m                                                        บ[0m
echo [93mบ Run this script from the directory where Stable Diffusion web UI      บ[0m
echo [93mบ should be located after installation.                                 บ[0m
echo [93mบ                                                                       บ[0m
echo [93mบ[0m [96mREINSTALLATION:[0m[93m                                                       บ[0m
echo [93mบ Place this script in the same directory as your current installation  บ[0m
echo [93mบ (not in the directory itself, but next to it) and specify the name of บ[0m
echo [93mบ the directory where you want to reinstall Stable Diffusion web UI.    บ[0m
echo [93mศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ[0m
echo.

@REM Specify a folder name
echo Specify a folder name where Stable Diffusion web UI will be (re)installed
echo or leave it blank to use the default [96mstable-diffusion-webui[0m name:
set /p INSTALL_DIR=^>ÿ
echo.

if "%INSTALL_DIR%"=="" (
  set INSTALL_DIR=stable-diffusion-webui
)

echo [93mInstallation directory full path:[0m [[96m%~dp0%INSTALL_DIR%[0m[93m][0m
choice /n /m:"Continue? [Y/N]: "
if errorlevel==2 (
  goto goodbye
)

@REM Check if the specified Stable Diffusion web UI folder exist
if exist !INSTALL_DIR! (
  echo [91m
  echo ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
  echo บ                                                                       บ
  echo บ                           ^^!^^!^^! WARNING ^^!^^!^^!                             บ
  echo บ                                                                       บ
  echo บ      This script will delete the current Stable Diffusion web UI      บ
  echo บ                installation in the specified folder^^!                  บ
  echo บ                                                                       บ
  echo บ              MAKE SURE YOU MAKE THE NECESSARY BACKUPS^^!                บ
  echo บ                                                                       บ
  echo ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ[0m
  echo.

  timeout /t 3 > nul
  choice /n /m:"Are you sure to continue? [Y/N]: "
  if errorlevel==2 (
    goto goodbye
  )
)

cls

@REM Rename current folder
if exist %INSTALL_DIR% (
  echo [93mRenaming [96m%INSTALL_DIR%[0m[93m to [0m[96m%INSTALL_DIR%_OLD[0m[93m...[0m
  echo.
  ren %INSTALL_DIR% "%INSTALL_DIR%_OLD" || ( goto error )
) else (
  echo [93mNo specified[0m [96m"%INSTALL_DIR%"[0m [93mfolder detected.
  echo Performing clean installation...[0m
  echo.
)

@REM Clone stable-diffusion-webui from the git repository.
git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git %INSTALL_DIR%
echo.

@REM Move some directories from the old stable-diffusion-webui
if exist %INSTALL_DIR%_OLD\pip (
  echo [93mMoving[0m [96mpip[0m[93m...[0m
  move /y %INSTALL_DIR%_OLD\pip %INSTALL_DIR% || ( goto error )
  echo.
)

if exist %INSTALL_DIR%_OLD\repositories (
  echo [93mMoving[0m [96mrepositories[0m[93m...[0m
  move /y %INSTALL_DIR%_OLD\repositories %INSTALL_DIR% || ( goto error )
  echo.
)

if exist %INSTALL_DIR%_OLD\venv (
  echo [93mMoving[0m [96mvenv[0m[93m...[0m
  move /y %INSTALL_DIR%_OLD\venv %INSTALL_DIR% || ( goto error )
  echo.
)

if exist %INSTALL_DIR%_OLD\models\Stable-diffusion (
  echo [93mMoving[0m [96mSD models[0m[93m...[0m
  move /y %INSTALL_DIR%_OLD\models\Stable-diffusion\* %INSTALL_DIR%\models\Stable-diffusion || ( goto error )
  echo.
)

if exist %INSTALL_DIR%_OLD\models\GFPGAN (
  echo [93mMoving[0m [96mGFPGAN models[0m[93m...[0m
  move /y %INSTALL_DIR%_OLD\models\GFPGAN %INSTALL_DIR%\models || ( goto error )
  echo.
)

if exist %INSTALL_DIR%_OLD\extensions (
 echo [93mMoving[0m [96mextensions[0m[93m...[0m
 robocopy "%~dp0%INSTALL_DIR%_OLD\extensions" "%~dp0%INSTALL_DIR%\extensions" /E /NJH /NJS /NDL /NC /NS /NP /NFL
 echo.
)

@REM Backup a few files, just in case.
if exist %INSTALL_DIR%_OLD\_PREV_INSTALL_FILES (
  move /y %INSTALL_DIR%_OLD\_PREV_INSTALL_FILES %INSTALL_DIR% || ( goto error )
)
set "SOURCE_DIR=%INSTALL_DIR%_OLD"
set TIMESTAMP=%DATE:~6,4%-%DATE:~3,2%-%DATE:~0,2%__%TIME:~0,2%%TIME:~3,2%%TIME:~6,2%
set "TARGET_DIR=%INSTALL_DIR%\_PREV_INSTALL_FILES\%TIMESTAMP%"
set "FILES_TO_COPY=webui-user.bat styles.csv config.json ui-config.json params.txt user.css"
if exist %SOURCE_DIR%\config_states (
 robocopy "%~dp0%SOURCE_DIR%\config_states" "%~dp0%TARGET_DIR%\config_states" /E /NJH /NJS /NDL /NC /NS /NP /NFL
)
if exist %SOURCE_DIR% (
  mkdir "%TARGET_DIR%" >nul 2>&1
	echo [93mMaking some backup files...[0m
  echo [93mCopying files to [0m[96m%TARGET_DIR%[0m[93m...[0m
  set /a COPIED_FILES=0
  for %%i in (%FILES_TO_COPY%) do (
    if exist "%SOURCE_DIR%\%%i" (
      copy "%SOURCE_DIR%\%%i" "%TARGET_DIR%\" >nul 2>&1
      set /a COPIED_FILES+=1
      echo [93mCopied[0m [96m%%i[0m
    )
  )
)
echo.

timeout /t 2 > nul

@REM There will be an error if you do the first installation and therefore there is no 'stable-diffusion-webui_OLD' directory
if exist %INSTALL_DIR%_OLD (
  echo [93mDeleting[0m [96m%INSTALL_DIR%_OLD[0m [93mdirectory...[0m
  rd /s /q %INSTALL_DIR%_OLD || ( goto error )
  echo.
)

@REM Find python system path
for /f "tokens=*" %%i in ('where python ^| findstr /c:"Program"') do (set PYTHON=%%i)

if exist %INSTALL_DIR%\venv (
  @REM Backup old venv and create new one
  ren "%INSTALL_DIR%\venv" "venv_OLD" || ( goto error )
  echo [93mCreating new[0m [96mvenv[0m[93m...[0m
  echo.
  cd %INSTALL_DIR%
  %PYTHON% -m venv venv
  cd ..

  @REM Move files from old venv skipping existing ones in new venv
  echo Moving venv files...
  robocopy "%~dp0%INSTALL_DIR%\venv_OLD" "%~dp0%INSTALL_DIR%\venv" /MOVE /E /XC /XN /XO /NJH /NJS /NDL /NC /NS /NP /NFL
  rd /s /q %~dp0%INSTALL_DIR%\venv_OLD || ( goto error )
  echo.

  @REM Add 'venv' to 'VENV_DIR='
  powershell -Command "(Get-Content '%INSTALL_DIR%\webui-user.bat') -Replace 'set VENV_DIR=.*', 'set VENV_DIR=venv' | Set-Content -Encoding ASCII -Path %INSTALL_DIR%\webui-user.bat"
  echo [93mTrying to update the[0m [96mwebui-user.bat[0m[93m file. Result:[0m
  findstr /I "VENV_DIR=" %INSTALL_DIR%\webui-user.bat
  echo.
)

@REM Check if 'v1-5-pruned-emaonly.safetensors' exist
echo [93mSearching for a SD models...[0m
set MODEL_PATH=%INSTALL_DIR%\models\Stable-diffusion\v1-5-pruned-emaonly.safetensors
if not exist %MODEL_PATH% (
  echo [96mv1-5-pruned-emaonly.safetensors[0m was not found. It is required for the first run.
  echo If you have one somewhere, specify the full path where it is located.
  echo Example: [7mD:\SD\DATA\models\Stable-diffusion[0m[90m\v1-5-pruned-emaonly.safetensors[0m
  echo You'll only need this thing once anyway. You can leave empty and just hit ENTER, then the model
  echo will be downloaded where it wants.
  echo.
) else (
  echo [96mv1-5-pruned-emaonly.safetensors[0m [93mfound.[0m
  echo.
  goto autolaunch
)

set "MODEL_PATH="
echo Full path to [96mv1-5-pruned-emaonly.safetensors[0m directory (if any):
set /p MODEL_PATH=^>ÿ
echo.

if "%MODEL_PATH%"=="" (
  goto autolaunch
)

if "%MODEL_PATH:~-1%" neq "\" (
  set "MODEL_PATH=%MODEL_PATH%\"
)

powershell -Command "(Get-Content %INSTALL_DIR%\webui-user.bat) -Replace 'set COMMANDLINE_ARGS=', ('$&--ckpt \"%MODEL_PATH%v1-5-pruned-emaonly.safetensors\" ') | Set-Content -Encoding ASCII -Path %INSTALL_DIR%\webui-user.bat"
echo [93mTrying to update the[0m [96mwebui-user.bat[0m[93m file. Result:[0m
findstr /I "COMMANDLINE_ARGS=" %INSTALL_DIR%\webui-user.bat
echo.

:autolaunch
@REM Open browser upon Stable Diffusion launch
choice /n /m:"Do you want to start a browser upon Stable Diffusion web UI launch? [Y/N]: "
echo.
if errorlevel==2 goto xformers
if errorlevel==1 (
  powershell -Command "(Get-Content %INSTALL_DIR%\webui-user.bat) -Replace 'set COMMANDLINE_ARGS=', ('$&--autolaunch ') | Set-Content -Encoding ASCII -Path %INSTALL_DIR%\webui-user.bat"
  echo [93mTrying to update the[0m [96mwebui-user.bat[0m[93m file. Result:[0m
  findstr /I "COMMANDLINE_ARGS=" %INSTALL_DIR%\webui-user.bat
  echo.
)

:xformers
@REM Enable --xformers
choice /n /m:"Do you want to enable --xformers? [Y/N]: "
echo.
if errorlevel==2 goto complete
if errorlevel==1 (
  powershell -Command "(Get-Content %INSTALL_DIR%\webui-user.bat) -Replace 'set COMMANDLINE_ARGS=', ('$&--xformers ') | Set-Content -Encoding ASCII -Path %INSTALL_DIR%\webui-user.bat"
  echo [93mTrying to update the[0m [96mwebui-user.bat[0m[93m file. Result:[0m
  findstr /I "COMMANDLINE_ARGS=" %INSTALL_DIR%\webui-user.bat
  echo.
)

:complete
echo [92mInstallation is complete^^![0m
echo.

@REM Run newly installed Stable Diffusion web UI
choice /n /m:"Do you want to run Stable Diffusion now? [Y/N]: "
echo.
if errorlevel==2 goto goodbye
if errorlevel==1 (
  echo [93mRunning[0m [96mwebui-user.bat[0m[93m...[0m
  echo.
  timeout /t 2 > nul
  cls
  cd %INSTALL_DIR%
  call webui-user.bat
)

:goodbye
echo.
echo [93mBye bye^^![0m
timeout /t 2 > nul
cls
exit /b

:error
echo.
echo [91mSomething went wrong. The script will terminate.[0m
echo.
echo [93mDon't panic^^! Here is what you do now:[0m
echo.
echo First, compare the size of the [96m%INSTALL_DIR%[0m and [96m%INSTALL_DIR%_OLD[0m directories.
echo.
echo If the size of the [96m%INSTALL_DIR%[0m is about 40MB, delete it. Rename [96m%INSTALL_DIR%_OLD[0m
echo back to [96m%INSTALL_DIR%[0m, find out what the error is and start over again.
echo Maybe the script failed to get write access.
echo.
echo If the [96m%INSTALL_DIR%[0m directory has a significant size (5-6GB or so), check if all critical data
echo has been moved from [96m%INSTALL_DIR%_OLD[0m. It is possible that the script could not get permission
echo to remove it. If this is the case, remove it manually.
echo.
echo And things like that. It's not exactly brain surgery, is it?
echo.
pause
exit /b 1
