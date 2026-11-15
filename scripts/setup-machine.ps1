<#
.SYNOPSIS
  Применяет рекомендованные глобальные настройки git на этой машине (Windows).

.EXAMPLE
  .\setup-machine.ps1 -Name "Ivan Petrov" -Email "you@example.com" -DryRun
  .\setup-machine.ps1 -Name "Ivan Petrov" -Email "you@example.com"

  Скрипт идемпотентен: повторный запуск ничего не ломает. Ничего не удаляет.
  Существующий ~/.gitmailmap сохраняется как ~/.gitmailmap.bak-<время>.
#>
param(
    [Parameter(Mandatory = $true)][string]$Name,
    [Parameter(Mandatory = $true)][string]$Email,
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$mailmapTemplate = Join-Path $root 'templates\.mailmap'
$mailmapTarget = Join-Path $HOME '.gitmailmap'

function Set-GitGlobal([string]$Key, [string]$Value) {
    $old = (git config --global --get $Key) 2>$null
    if ($old -eq $Value) { Write-Host ("  ok      {0} = {1}" -f $Key, $Value); return }
    $was = if ($old) { "было '$old'" } else { 'не было' }
    if ($DryRun) { Write-Host ("  [dry]   {0} = {1}   ({2})" -f $Key, $Value, $was); return }
    git config --global $Key $Value
    Write-Host ("  set     {0} = {1}   ({2})" -f $Key, $Value, $was)
}

Write-Host "== Личность"
Set-GitGlobal 'user.name'  $Name
Set-GitGlobal 'user.email' $Email

Write-Host "== Поведение"
Set-GitGlobal 'pull.rebase'          'true'
Set-GitGlobal 'rebase.autoStash'     'true'
Set-GitGlobal 'rebase.autoSquash'    'true'
Set-GitGlobal 'fetch.prune'          'true'
Set-GitGlobal 'push.autoSetupRemote' 'true'
Set-GitGlobal 'core.autocrlf'        'input'
Set-GitGlobal 'merge.conflictStyle'  'zdiff3'

Write-Host "== .mailmap"
if (-not (Test-Path $mailmapTemplate)) { throw "Нет шаблона: $mailmapTemplate" }
$content = (Get-Content $mailmapTemplate -Raw -Encoding UTF8).Replace('__NAME__', $Name).Replace('__EMAIL__', $Email)
$same = (Test-Path $mailmapTarget) -and ((Get-Content $mailmapTarget -Raw -Encoding UTF8) -eq $content)
if ($same) {
    Write-Host "  ok      $mailmapTarget уже актуален"
} elseif ($DryRun) {
    Write-Host "  [dry]   записать $mailmapTarget"
} else {
    if (Test-Path $mailmapTarget) {
        $bak = "$mailmapTarget.bak-$(Get-Date -Format yyyyMMdd-HHmmss)"
        Copy-Item $mailmapTarget $bak
        Write-Host "  backup  $bak"
    }
    # UTF-8 без BOM, LF — git так читает надёжнее
    [System.IO.File]::WriteAllText($mailmapTarget, ($content -replace "`r`n", "`n"), (New-Object System.Text.UTF8Encoding($false)))
    Write-Host "  write   $mailmapTarget"
}
# git ожидает прямые слеши в пути
Set-GitGlobal 'mailmap.file' ($mailmapTarget -replace '\\', '/')

Write-Host ""
Write-Host "Готово. Проверьте:  git config --global --list --show-origin"
Write-Host "Дальше: .gitattributes в репозитории (03-line-endings-gitattributes.md) и SSH (04-ssh-gitverse.md)."

exit 0
