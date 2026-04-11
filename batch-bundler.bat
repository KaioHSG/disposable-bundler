@echo off

set "output=script.bat"
set "launcher=start.bat"
set "src_path=.\src"

set "zr=7zr.exe"
set "zf=7z-file.7z"

pushd "%src_path%"
if exist "%~dp0\%zf%" ("%~dp0\%zr%" u "%~dp0\%zf%" -up1y0  "*" -r -ssw) else ("%~dp0\%zr%" a "%~dp0\%zf%" "*")
pushd "%~dp0"

if exist *.hex del *.hex
certutil -f -encodehex "%zr%" zr.hex 12
certutil -f -encodehex "%zf%" zf.hex 12
(
    echo @echo off
    echo set "p=%%temp%%\%%random%%"
    echo md "%%p%%"
    echo powershell -c "$h=gc '%%~f0'; $h[11] | sc '%%p%%\z.h'; $h[12] | sc '%%p%%\f.h'"
    echo certutil -decodehex "%%p%%\z.h" "%%p%%\z.exe" ^>nul
    echo certutil -decodehex "%%p%%\f.h" "%%p%%\f.7z" ^>nul
    echo "%%p%%\z.exe" x "%%p%%\f.7z" -o"%%p%%" -y ^>nul
    echo pushd "%%p%%"
    echo start /b /wait "" "%%p%%\%launcher%"
    echo pushd "%%~dp0"
    echo rd /s /q "%%p%%"
    echo exit /b
    type zr.hex
    type zf.hex
) > "%output%"
exit /b