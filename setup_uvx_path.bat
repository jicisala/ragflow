@echo off
echo 正在设置 uvx 环境变量...

REM 添加 Python Scripts 目录到用户 PATH
setx PATH "%PATH%;C:\Users\songshangru\AppData\Local\Programs\Python\Python312\Scripts"

echo 环境变量已设置完成！
echo 请重启 Context7 或重新打开命令行窗口以使更改生效。
echo.
echo 测试 uvx 命令：
"C:\Users\songshangru\AppData\Local\Programs\Python\Python312\Scripts\uvx.exe" --version

pause
