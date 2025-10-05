@echo off
setlocal enabledelayedexpansion

:: --- Default values ---
set "outfile=checked-code.txt"
set "extensions=.js .ts .jsx .tsx .html .css .scss .json .md .bat .cmd .ps1 .py .java .cpp .c .h .hpp .cs .php .rb .sh .xml .yml .yaml"
set "ignoreFolders=.vscode node_modules .git"

:: --- Parse arguments ---
:parse_args
if "%~1"=="" goto after_args

if /i "%~1"=="-f" (
    set "outfile=%~2"
    shift & shift
    goto parse_args
)

if /i "%~1"=="-e" (
    set "extensions=%~2"
    shift & shift
    goto parse_args
)

if /i "%~1"=="-i" (
    set "ignoreFolders=%~2"
    shift & shift
    goto parse_args
)

if /i "%~1"=="-h" (
    call :show_help
    exit /b 0
)

shift
goto parse_args

:after_args

set "scriptName=%~f0"
set /a "fileCount=0"

echo.
echo ------------------------------------------------------------
echo  Collecting code files...
echo ------------------------------------------------------------
echo Output file: %outfile%
echo Extensions : %extensions%
echo Ignored folders: %ignoreFolders%
echo Skipping script: %scriptName%
echo ------------------------------------------------------------
echo.

:: --- Traverse all files recursively ---
for /r %%F in (*) do (
    set "file=%%F"
    set "skip="
    set "ext=%%~xF"
    set "folder=%%~dpF"

    :: --- Skip this script itself ---
    if /i "!file!"=="%scriptName%" set "skip=1"

    :: --- Check ignored folders ---
    for %%I in (%ignoreFolders%) do (
        echo !folder! | findstr /i "\\%%I\\" >nul
        if not errorlevel 1 set "skip=1"
    )

    :: --- If not skipped, check extension ---
    if not defined skip (
        for %%E in (%extensions%) do (
            if /i "%%E"=="!ext!" (
                if !fileCount! EQU 0 (
                    :: --- Create output file only once, when first match found ---
                    echo ==== Combined Code Files ==== > "%outfile%"
                    echo [Created output file: %outfile%]
                )
                set /a "fileCount+=1"
                echo [Adding] !file!
                >> "%outfile%" echo --------------------------------------------------
                >> "%outfile%" echo FILE: !file!
                >> "%outfile%" echo --------------------------------------------------
                type "!file!" >> "%outfile%"
                echo. >> "%outfile%"
                echo. >> "%outfile%"
            )
        )
    )
)

if %fileCount% EQU 0 (
    echo [!] No matching code files found. No file created.
    if exist "%outfile%" del "%outfile%"
) else (
    echo [OK] Finished collecting %fileCount% files into %outfile%.
)

pause
endlocal
exit /b 0


:: -----------------------------------------------------------------
::  Helper Section (-h)
:: -----------------------------------------------------------------
:show_help
echo.
echo =============================================================
echo  collect_code.bat - Combine code files into one text file
echo =============================================================
echo.
echo  USAGE:
echo    collect_code.bat [options]
echo.
echo  OPTIONS:
echo    -f [filename]   Set output file name  (default: checked-code.txt)
echo    -e [extensions] Space-separated list of extensions to include
echo                    (default: common code file types)
echo    -i [folders]    Space-separated list of folders to ignore
echo                    (default: .vscode node_modules .git)
echo    -h              Show this help information
echo.
echo  EXAMPLES:
echo    collect_code.bat
echo    collect_code.bat -f all.txt
echo    collect_code.bat -e ".js .py .html"
echo    collect_code.bat -i "node_modules dist build"
echo    collect_code.bat -f output.txt -e ".js .ts" -i ".git .vscode"
echo.
echo  NOTES:
echo    - The script searches recursively in all subfolders.
echo    - The output file is only created if at least one match is found.
echo    - The script file itself is automatically skipped.
echo    - ASCII-only output for maximum compatibility.
echo =============================================================
echo.
exit /b 0
