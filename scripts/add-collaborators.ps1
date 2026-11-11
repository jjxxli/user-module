<#
.SYNOPSIS
    批量把组员添加为 GitHub 仓库协作者（默认 push 权限：可以推自己的分支、开 PR）。

.DESCRIPTION
    - 复用本机 Git 已保存的 GitHub 凭据（Windows 凭据管理器 / Git Credential Manager），
      不会把 token 打印到屏幕，也不会写入任何文件。
    - 调用 GitHub REST API：PUT /repos/{owner}/{repo}/collaborators/{username}
    - 协作者会收到 GitHub 邮件邀请，需要对方在自己的 GitHub 账号里点「接受邀请」后才会生效。
    - 前提：本机已完成过一次 GitHub 登录（例如 git push / gh auth login），
      且当前账号对该仓库有 admin 权限。

.PARAMETER Usernames
    组员的 GitHub 用户名，多个用逗号或空格分隔。

.PARAMETER Permission
    pull（只读）/ triage / push（默认，推荐）/ maintain / admin。

.PARAMETER Repo
    仓库全名，默认 jjxxli/user-module。

.EXAMPLE
    pwsh -File .\scripts\add-collaborators.ps1 -Usernames xiaoming,lisi

.EXAMPLE
    pwsh -File .\scripts\add-collaborators.ps1 -Usernames xiaoming -Permission push

.NOTES
    仓库地址：https://github.com/jjxxli/user-module
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string[]]$Usernames,

    [ValidateSet('pull', 'triage', 'push', 'maintain', 'admin')]
    [string]$Permission = 'push',

    [string]$Repo = 'jjxxli/user-module'
)

$ErrorActionPreference = 'Stop'

# ---------- 1. 从本机 Git 凭据中读取 token（不打印） ----------
$credLines = "protocol=https`nhost=github.com`n`n" | git credential fill 2>$null
$token = ($credLines | Where-Object { $_ -match '^password=' }) -replace '^password=', ''
if ([string]::IsNullOrWhiteSpace($token)) {
    throw '未找到 GitHub 凭据。请先在本机完成一次 GitHub 登录（例如先手动 git push 一次），或安装 Git Credential Manager 后重试。'
}

$headers = @{
    Authorization = "token $token"
    'User-Agent'  = 'add-collaborators'
    Accept        = 'application/vnd.github+json'
}

# ---------- 2. 确认仓库可访问 ----------
$repoInfo = Invoke-RestMethod -Uri "https://api.github.com/repos/$Repo" -Headers $headers -Method Get -TimeoutSec 30
Write-Host ("仓库：{0}（{1}）" -f $repoInfo.full_name, $(if ($repoInfo.private) { '私有' } else { '公开' })) -ForegroundColor Cyan

# ---------- 3. 逐个添加 ----------
$invited = @()
$already = @()
$failed  = @()

foreach ($user in $Usernames) {
    $user = $user.Trim().TrimStart('@')
    if ([string]::IsNullOrWhiteSpace($user)) { continue }

    $body = @{ permission = $Permission } | ConvertTo-Json -Compress
    $uri  = "https://api.github.com/repos/$Repo/collaborators/$user"

    try {
        $resp = Invoke-RestMethod -Uri $uri -Method Put -Headers $headers `
            -Body ([Text.Encoding]::UTF8.GetBytes($body)) -ContentType 'application/json; charset=utf-8' -TimeoutSec 30

        if ($resp.invitation_id) {
            $invited += $user
            Write-Host ("  ✔ 已发送邀请：{0}（权限 {1}，邀请 ID {2}）" -f $user, $Permission, $resp.invitation_id) -ForegroundColor Green
        }
        else {
            $already += $user
            Write-Host ("  ✔ 已是协作者：{0}（权限已更新为 {1}）" -f $user, $Permission) -ForegroundColor Green
        }
    }
    catch {
        $status = $null
        if ($_.Exception.Response) { $status = [int]$_.Exception.Response.StatusCode }
        switch ($status) {
            404 { Write-Host ("  ✘ 找不到用户：{0}（用户名拼写是否正确？）" -f $user) -ForegroundColor Red }
            422 { Write-Host ("  ✘ 无法添加：{0}（对方已是协作者或用户名无效）" -f $user) -ForegroundColor Yellow }
            403 { Write-Host ("  ✘ 没有权限添加协作者：请确认当前 GitHub 账号是仓库 Owner" ) -ForegroundColor Red }
            default { Write-Host ("  ✘ 添加失败：{0} -> {1}" -f $user, $_.Exception.Message) -ForegroundColor Red }
        }
        $failed += $user
    }
}

# ---------- 4. 汇总 ----------
Write-Host ''
Write-Host '---------------- 汇总 ----------------'
if ($invited.Count -gt 0) { Write-Host ("已发送邀请（{0}）：{1}" -f $invited.Count, ($invited -join ', ')) }
if ($already.Count -gt 0) { Write-Host ("已是协作者（{0}）：{1}" -f $already.Count, ($already -join ', ')) }
if ($failed.Count  -gt 0) { Write-Host ("失败（{0}）：{1}" -f $failed.Count, ($failed -join ', ')) -ForegroundColor Red }

if ($invited.Count -gt 0) {
    Write-Host ''
    Write-Host '提醒：邀请需要组员在 GitHub 上「接受」后生效。' -ForegroundColor Cyan
    Write-Host '  - 接受入口：https://github.com/notifications （或仓库页面的邀请横幅）'
    Write-Host ('  - 仓库协作者页：https://github.com/{0}/settings/access' -f $Repo)
    Write-Host '  - 他们接受后，把 @用户名 追加到 .github/CODEOWNERS 对应行，即可自动指派审查。'
}
Write-Host '--------------------------------------'
