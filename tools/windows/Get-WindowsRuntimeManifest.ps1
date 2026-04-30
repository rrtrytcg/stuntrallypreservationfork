[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$RuntimeDir = "",

    [Parameter(Mandatory = $false)]
    [string]$OutputPath
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

$runtimePath = Resolve-FullPath $RuntimeDir
if (-not (Test-Path -LiteralPath $runtimePath -PathType Container)) {
    throw "RuntimeDir not found: $runtimePath"
}

$patterns = @("*.exe", "*.dll", "*.cfg", "*.bat")
$files = foreach ($pattern in $patterns) {
    Get-ChildItem -LiteralPath $runtimePath -Filter $pattern -File -ErrorAction SilentlyContinue
}

$manifest = $files |
    Sort-Object Name |
    ForEach-Object {
        $hash = Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256
        [PSCustomObject]@{
            RelativePath  = $_.Name
            SizeBytes     = $_.Length
            LastWriteTime = $_.LastWriteTime.ToString("o")
            SHA256        = $hash.Hash.ToLowerInvariant()
        }
    }

if ($OutputPath) {
    $outputFullPath = Resolve-FullPath $OutputPath
    $outputDir = Split-Path -Parent $outputFullPath
    if ($outputDir -and -not (Test-Path -LiteralPath $outputDir)) {
        New-Item -ItemType Directory -Path $outputDir | Out-Null
    }
    $manifest | Export-Csv -LiteralPath $outputFullPath -NoTypeInformation
    Write-Host "Wrote runtime manifest: $outputFullPath"
} else {
    $manifest | Format-Table -AutoSize
}
