[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ManifestPath,

    [Parameter(Mandatory = $false)]
    [string]$RuntimeDir = ""
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

$manifestFullPath = Resolve-FullPath $ManifestPath
$runtimePath = Resolve-FullPath $RuntimeDir

if (-not (Test-Path -LiteralPath $manifestFullPath -PathType Leaf)) {
    throw "Manifest not found: $manifestFullPath"
}
if (-not (Test-Path -LiteralPath $runtimePath -PathType Container)) {
    throw "RuntimeDir not found: $runtimePath"
}

$expected = Import-Csv -LiteralPath $manifestFullPath
$failures = New-Object System.Collections.Generic.List[string]

foreach ($entry in $expected) {
    $filePath = Join-Path $runtimePath $entry.RelativePath
    if (-not (Test-Path -LiteralPath $filePath -PathType Leaf)) {
        $failures.Add("Missing: $($entry.RelativePath)")
        continue
    }

    $item = Get-Item -LiteralPath $filePath
    $hash = (Get-FileHash -LiteralPath $filePath -Algorithm SHA256).Hash.ToLowerInvariant()

    if ([string]$item.Length -ne [string]$entry.SizeBytes) {
        $failures.Add("Size changed: $($entry.RelativePath) expected $($entry.SizeBytes), got $($item.Length)")
    }
    if ($hash -ne $entry.SHA256) {
        $failures.Add("Hash changed: $($entry.RelativePath)")
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { [Console]::Error.WriteLine($_) }
    exit 1
}

Write-Host "Runtime manifest matches: $manifestFullPath"
