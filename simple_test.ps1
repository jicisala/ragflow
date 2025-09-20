Write-Host "=== 测试 uvx 环境变量设置 ==="

# 检查 uvx.exe 文件是否存在
$uvxPath = "C:\Users\songshangru\AppData\Local\Programs\Python\Python312\Scripts\uvx.exe"
if (Test-Path $uvxPath) {
    Write-Host "✓ uvx.exe 文件存在"
} else {
    Write-Host "✗ uvx.exe 文件不存在"
    exit 1
}

# 添加到当前会话的 PATH
$scriptsPath = "C:\Users\songshangru\AppData\Local\Programs\Python\Python312\Scripts"
$env:PATH = $env:PATH + ";" + $scriptsPath

# 测试 uvx 命令
Write-Host "测试 uvx 命令:"
uvx --version

Write-Host "✓ 环境变量设置完成！"
Write-Host "现在可以在 Context7 中使用 'uvx mcp-datetime' 命令了。"
