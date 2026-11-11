# ============================================================
# 安装 Git 本地钩子：把 core.hooksPath 指向仓库内的 .githooks 目录
# 用法（在仓库根目录或任意位置执行）：
#   powershell -ExecutionPolicy Bypass -File scripts/install-hooks.ps1
# 或使用 PowerShell 7：
#   pwsh -File scripts/install-hooks.ps1
# ============================================================
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

# 仓库根目录 = 本脚本所在目录的上一级
$scriptDir = $PSScriptRoot
$repoRoot = (Resolve-Path (Join-Path $scriptDir '..')).Path
$hooksDir = Join-Path $repoRoot '.githooks'

if (-not (Test-Path $hooksDir)) {
    Write-Host " ❌ 未找到 .githooks 目录，请确认脚本位于 <仓库根>/scripts/ 下。 " -ForegroundColor Red
    exit 1
}

Push-Location $repoRoot
try {
    # 1. 设置本地 git 配置：钩子从仓库内的 .githooks 读取
    git config core.hooksPath .githooks
    if ($LASTEXITCODE -ne 0) {
        throw "git config core.hooksPath 执行失败（exit code: $LASTEXITCODE），请确认已安装 Git for Windows。 "
    }

    $hooksPath = git config --get core.hooksPath

    # 2. Windows 下 Git 通过 sh 解释执行钩子，不需要 chmod；
    #    如果仓库同时被 WSL / Linux 使用，请再运行 scripts/install-hooks.sh 或手动 chmod +x。
    Write-Host ''
    Write-Host ' ✅ Git 本地钩子安装完成。 ' -ForegroundColor Green
    Write-Host "   仓库：$repoRoot"
    Write-Host "   core.hooksPath = $hooksPath"
    Write-Host '   已启用钩子： '
    Get-ChildItem -Path $hooksDir -File | ForEach-Object {
        Write-Host ("     - " + $_.Name)
    }
    Write-Host ''
    Write-Host ' 提示：钩子只影响本地提交；push 后仍会经过 GitHub Actions CI 检查。 '
    Write-Host '     提交信息格式：<type>(<scope>): <subject>，例如 feat(user): 新增查询接口 '
}
finally {
    Pop-Location
}
