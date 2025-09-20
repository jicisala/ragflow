# 测试 uvx 环境变量设置
Write-Host "=== 测试 uvx 环境变量设置 ==="
Write-Host ""

# 检查 uvx.exe 文件是否存在
$uvxPath = "C:\Users\songshangru\AppData\Local\Programs\Python\Python312\Scripts\uvx.exe"
if (Test-Path $uvxPath) {
    Write-Host "✓ uvx.exe 文件存在: $uvxPath"
} else {
    Write-Host "✗ uvx.exe 文件不存在: $uvxPath"
    exit 1
}

# 检查当前 PATH 环境变量
$currentPath = $env:PATH
$scriptsPath = "C:\Users\songshangru\AppData\Local\Programs\Python\Python312\Scripts"

if ($currentPath -like "*$scriptsPath*") {
    Write-Host "✓ Python Scripts 目录已在当前会话的 PATH 中"
} else {
    Write-Host "✗ Python Scripts 目录不在当前会话的 PATH 中"
    Write-Host "正在添加到当前会话..."
    $env:PATH = $env:PATH + ";" + $scriptsPath
}

# 检查用户级别的 PATH 环境变量
$userPath = [Environment]::GetEnvironmentVariable("PATH", [EnvironmentVariableTarget]::User)
if ($userPath -like "*$scriptsPath*") {
    Write-Host "✓ Python Scripts 目录已在用户 PATH 环境变量中"
} else {
    Write-Host "✗ Python Scripts 目录不在用户 PATH 环境变量中"
    Write-Host "正在添加到用户 PATH..."
    $newUserPath = $userPath + ";" + $scriptsPath
    [Environment]::SetEnvironmentVariable("PATH", $newUserPath, [EnvironmentVariableTarget]::User)
    Write-Host "✓ 已添加到用户 PATH 环境变量"
}

# 测试 uvx 命令
Write-Host ""
Write-Host "测试 uvx 命令:"
try {
    $version = & uvx --version 2>&1
    Write-Host "✓ uvx 命令可用: $version"
} catch {
    Write-Host "✗ uvx 命令不可用: $($_.Exception.Message)"
}

# 测试 mcp-datetime
Write-Host ""
Write-Host "测试 uvx mcp-datetime (快速测试):"
try {
    $process = Start-Process -FilePath "uvx" -ArgumentList "mcp-datetime", "--help" -PassThru -WindowStyle Hidden
    Start-Sleep -Seconds 3
    if (!$process.HasExited) {
        $process.Kill()
        Write-Host "✓ uvx mcp-datetime 可以启动"
    } else {
        Write-Host "? uvx mcp-datetime 进程已退出"
    }
} catch {
    Write-Host "✗ uvx mcp-datetime 启动失败: $($_.Exception.Message)"
}

Write-Host ""
Write-Host "=== 设置完成 ==="
Write-Host "请重启 Context7 以使环境变量更改生效。"
