[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$RuntimeDir = "",

    [Parameter(Mandatory = $false)]
    [switch]$RunEditor,

    [Parameter(Mandatory = $false)]
    [string]$ArgumentList = "check",

    [Parameter(Mandatory = $false)]
    [int]$TimeoutSeconds = 45
)

$ErrorActionPreference = "Stop"

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $RuntimeDir) {
    $RuntimeDir = Join-Path $scriptRoot "..\..\windows binaries\Stunt Rally 3.3\bin\Release"
}

function Resolve-FullPath {
    param([string]$Path)
    if ([System.IO.Path]::IsPathRooted($Path)) {
        return [System.IO.Path]::GetFullPath($Path)
    }
    return [System.IO.Path]::GetFullPath((Join-Path (Get-Location) $Path))
}

function Invoke-Smoke {
    param(
        [string]$ExePath,
        [string]$ExeArgs,
        [int]$Timeout
    )

    if (-not (Test-Path -LiteralPath $ExePath -PathType Leaf)) {
        throw "Executable not found: $ExePath"
    }

    Write-Host "Starting smoke: $ExePath $ExeArgs"
    $process = Start-Process -FilePath $ExePath -ArgumentList $ExeArgs -WorkingDirectory (Split-Path -Parent $ExePath) -PassThru -WindowStyle Hidden

    if (-not $process.WaitForExit($Timeout * 1000)) {
        Write-Warning "Smoke timed out after $Timeout seconds; stopping process id $($process.Id)."
        Stop-Process -Id $process.Id -Force
        return 124
    }

    return $process.ExitCode
}

$runtimePath = Resolve-FullPath $RuntimeDir
if (-not (Test-Path -LiteralPath $runtimePath -PathType Container)) {
    throw "RuntimeDir not found: $runtimePath"
}

$gameExe = Join-Path $runtimePath "StuntRally3.exe"
$gameExit = Invoke-Smoke -ExePath $gameExe -ExeArgs $ArgumentList -Timeout $TimeoutSeconds
Write-Host "Game smoke exit code: $gameExit"

if ($RunEditor) {
    $editorExe = Join-Path $runtimePath "SR-Editor3.exe"
    $editorExit = Invoke-Smoke -ExePath $editorExe -ExeArgs $ArgumentList -Timeout $TimeoutSeconds
    Write-Host "Editor smoke exit code: $editorExit"
}

$logRoot = Join-Path $env:APPDATA "stuntrally3"
Write-Host "Expected log/config directory: $logRoot"
if (Test-Path -LiteralPath $logRoot -PathType Container) {
    Get-ChildItem -LiteralPath $logRoot -File |
        Where-Object { $_.Name -match "^(Ogre|Ogre_ed|MyGUI|MyGUI_ed|game|editor|ogre|ogre_ed)\.(log|cfg)$" } |
        Sort-Object Name |
        Select-Object Name, Length, LastWriteTime |
        Format-Table -AutoSize
}

if ($gameExit -ne 0) {
    exit $gameExit
}
