<#
.SYNOPSIS
    Create or remove a Windows symbolic link (used to wire dotfiles into $HOME).

.DESCRIPTION
    Defaults to linking .\opencode -> $HOME\.config\opencode, mirroring the
    symlinks.conf:12 entry applied by the macOS/Ubuntu installer. Override
    with -Source / -Target. Use -Delete to remove a previously created link.

    The script self-elevates to Administrator on launch: if the current session
    is not elevated, it re-launches itself with -Verb RunAs, which shows the
    standard UAC prompt. Accept it, and the elevated instance does the work
    in a new window and stays open with its output so you can read the result.
    Decline, and the script exits without making changes.

    Note: the UAC prompt is required even if you have Developer Mode enabled,
    because the script always asks for elevation rather than probing Dev Mode.

.PARAMETER Source
    Existing folder/file the link points to. Default: <repo>\opencode.
.PARAMETER Target
    Path of the link to create. Default: $HOME\.config\opencode.
.PARAMETER Delete
    Remove the link at -Target instead of creating one. Refuses to touch a
    path that is not a reparse point (symlink/junction).

.EXAMPLE
    .\win-make-symlink.ps1
    # Creates the default test link.

.EXAMPLE
    .\win-make-symlink.ps1 -Source ".\nvim" -Target "$HOME\.config\nvim"

.EXAMPLE
    .\win-make-symlink.ps1 -Target "$HOME\.config\opencode" -Delete
#>
[CmdletBinding()]
param(
    [string]$Source,
    [string]$Target = (Join-Path $HOME '.config\opencode'),
    [switch]$Delete
)

$ErrorActionPreference = 'Stop'

# Resolve the default $Source after param() so we can use a robust fallback
# chain (PSCommandPath -> PSScriptRoot -> CWD). This avoids relying on
# $PSScriptRoot being populated at param-default-evaluation time, which
# fails under -File invocations where the engine hasn't bound a file path
# (and any non-file invocation such as Invoke-Expression).
if (-not $Source) {
    $scriptRoot = $null
    if (-not [string]::IsNullOrEmpty($PSCommandPath)) {
        $scriptRoot = [System.IO.Path]::GetDirectoryName($PSCommandPath)
    }
    if ([string]::IsNullOrEmpty($scriptRoot) -and -not [string]::IsNullOrEmpty($PSScriptRoot)) {
        $scriptRoot = $PSScriptRoot
    }
    if ([string]::IsNullOrEmpty($scriptRoot)) {
        $scriptRoot = (Get-Location).Path
    }
    $Source = Join-Path $scriptRoot 'opencode'
}

# Convert $Source and $Target to absolute paths in THIS (unelevated) scope.
# The elevated child spawned via -Verb RunAs can see a different $HOME than
# the unelevated session (e.g. C:\Users\Administrator if the user is
# elevated into a different account), and its CWD defaults to
# C:\Windows\system32. If we let it re-evaluate any relative default or
# rely on its own $HOME, the symlink lands in the wrong profile. Resolving
# to absolute paths here means the elevated child receives the unelevated
# user's view of both arguments.
#
# We use IsPathRooted + Join-Path + the 1-arg GetFullPath because the
# 2-arg GetFullPath overload is .NET Core 2.1+ only and does not exist in
# .NET Framework 4.x (used by Windows PowerShell 5.1). The 1-arg version
# also normalizes segments like ".\" so the result is a clean absolute path.
$unelevatedCwd = (Get-Location).Path
if (-not [System.IO.Path]::IsPathRooted($Source)) { $Source = Join-Path $unelevatedCwd $Source }
if (-not [System.IO.Path]::IsPathRooted($Target)) { $Target = Join-Path $unelevatedCwd $Target }
$Source = [System.IO.Path]::GetFullPath($Source)
$Target = [System.IO.Path]::GetFullPath($Target)

# Self-elevate to Administrator. If the current session is not elevated,
# re-launch this script with -Verb RunAs to trigger the UAC prompt. The
# elevated instance does the work in a new window; -NoExit keeps that
# window open after the script finishes so the output (success or error)
# is readable. This (non-elevated) process exits as soon as Start-Process
# returns.
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator)) {
    if ([string]::IsNullOrEmpty($PSCommandPath)) {
        Write-Error "Cannot self-elevate: invoke the script as a file (e.g. '.\win-make-symlink.ps1'), not from stdin or -Command."
        exit 1
    }
    Write-Host "Requesting administrator privileges..." -ForegroundColor Cyan

    # Pass -Source, -Target, and -Delete explicitly. The values were
    # resolved to absolute paths in the unelevated scope just above, so
    # the elevated child receives the unelevated user's paths rather
    # than re-evaluating the param() defaults against its own $HOME
    # and CWD.
    $argList = "-NoExit -NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    $argList += " -Source `"$Source`""
    $argList += " -Target `"$Target`""
    if ($Delete) { $argList += " -Delete" }

    try {
        Start-Process -FilePath 'powershell.exe' -ArgumentList $argList -Verb RunAs -ErrorAction Stop | Out-Null
    } catch {
        Write-Error "Administrator privileges were not granted. Re-run this script from an elevated PowerShell session."
        exit 1
    }
    exit 0
}

if ($Delete) {
    if (-not (Test-Path -LiteralPath $Target)) {
        Write-Host "Nothing to delete: '$Target' does not exist." -ForegroundColor Yellow
        exit 0
    }
    $item = Get-Item -LiteralPath $Target -Force
    $isReparse = ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0
    if (-not $isReparse) {
        Write-Error "Refusing to delete '$Target' - not a symlink or junction. Remove it manually."
        exit 1
    }
    Remove-Item -LiteralPath $Target -Force
    Write-Host "Removed symlink: $Target" -ForegroundColor Green
    exit 0
}

if (-not (Test-Path -LiteralPath $Source)) {
    Write-Error "Source not found: $Source"
    exit 1
}

$sourceFull = (Resolve-Path -LiteralPath $Source).Path
$targetFull = [System.IO.Path]::GetFullPath($Target)

if (Test-Path -LiteralPath $targetFull) {
    Write-Error "Target already exists: $targetFull (use -Delete to remove it first)"
    exit 1
}

$targetParent = Split-Path -Path $targetFull -Parent
if (-not (Test-Path -LiteralPath $targetParent)) {
    New-Item -ItemType Directory -Path $targetParent -Force | Out-Null
    Write-Host "Created parent: $targetParent"
}

try {
    New-Item -ItemType SymbolicLink -Path $targetFull -Target $sourceFull -Force | Out-Null
} catch {
    Write-Error @"
Failed to create symlink. On Windows this requires either:
  1. Run PowerShell as Administrator, OR
  2. Enable Developer Mode (Settings > Privacy & security > For developers).

Underlying error: $($_.Exception.Message)
"@
    exit 1
}

Write-Host "Created symlink:" -ForegroundColor Green
Write-Host "  $targetFull  ->  $sourceFull"
