@echo off
echo Testing uvx setup...
echo.

echo Checking if uvx.exe exists...
if exist "C:\Users\songshangru\AppData\Local\Programs\Python\Python312\Scripts\uvx.exe" (
    echo ✓ uvx.exe found
) else (
    echo ✗ uvx.exe not found
    pause
    exit /b 1
)

echo.
echo Testing uvx command...
uvx --version
if %errorlevel% equ 0 (
    echo ✓ uvx command works!
) else (
    echo ✗ uvx command failed
)

echo.
echo Environment setup complete!
echo You can now use 'uvx mcp-datetime' in Context7.
echo.
pause
