:: Use: .\disposable-bundler.cmd "My Program" . . false

@echo off

:: Name of the final generated file.
set "output=My Script"

:: Entry point file to be executed inside the bundle.
set "launcher=start.cmd"

:: Directory containing the files to pack.
set "srcpath=src"

:: Use "true" to hide the console, "false" to keep it visible.
set gui=false

if not "%~1"=="" if not "%~1"=="." set "output=%~1"
if not "%~2"=="" if not "%~2"=="." set "launcher=%~2"
if not "%~3"=="" if not "%~3"=="." set "srcpath=%~3"
if not "%~4"=="" if not "%~4"=="." set "gui=%~4"

echo Disposable Bundler

if not exist "%srcpath%" (
    md "%srcpath%"
    echo echo Hello World! ^& pause ^& exit > "%srcpath%\%launcher%"
)

if exist "%temp%\disposable-bundler" rd /s /q "%temp%\disposable-bundler"
md "%temp%\disposable-bundler"

tar -czvf "%temp%\disposable-bundler\bundle.tar.gz" -C "%srcpath%" .
certutil -f -encode "%temp%\disposable-bundler\bundle.tar.gz" "%temp%\disposable-bundler\bundle.b64" || exit /b

(
    echo @echo off

    echo :rp
    echo set "p=%%temp%%\%%random%%"
    echo if exist "%%p%%" goto :rp

    echo md "%%p%%"
    echo pushd "%%p%%"

    if %gui%==true (
        echo echo Starting %output%...
        echo if "%%1" neq "hide" echo CreateObject^("Shell.Application"^).ShellExecute "%%~s0", "hide",,, 0 ^> hide.vbs ^&^& call hide.vbs ^&^& goto :ce
    )

    echo certutil -decode "%%~f0" bundle.tar.gz ^>nul
    echo tar -xzf bundle.tar.gz -C .

    if %gui%==true (
        echo call %launcher%
    ) else (
        echo call %launcher% %%*
    )

    echo :ce
    echo popd
    echo rd /s /q "%%p%%"
    echo exit /b

    type "%temp%\disposable-bundler\bundle.b64"
) > "%output%.cmd"

rd /s /q "%temp%\disposable-bundler"
exit /b
