[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory = $true)]
    [string]$SourceDir,

    [Parameter(Mandatory = $false)]
    [string]$RuntimeDir = "",

    [Parameter(Mandatory = $false)]
    [switch]$IncludeDirect3D11
)

$ErrorActionPreference = "Stop"

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $RuntimeDir) {
    $RuntimeDir = Join-Path $scriptRoot "..\..\bin\Release"
}

function Resolve-FullPath {
    param([string]$Path)
    if ([System.IO.Path]::IsPathRooted($Path)) {
        return [System.IO.Path]::GetFullPath($Path)
    }
    return [System.IO.Path]::GetFullPath((Join-Path (Get-Location) $Path))
}

$sourcePath = Resolve-FullPath $SourceDir
$runtimePath = Resolve-FullPath $RuntimeDir

if (-not (Test-Path -LiteralPath $sourcePath -PathType Container)) {
    throw "SourceDir not found: $sourcePath"
}
if (-not (Test-Path -LiteralPath $runtimePath -PathType Container)) {
    New-Item -ItemType Directory -Path $runtimePath | Out-Null
}

$dlls = @(
    "MyGUIEngine.dll",
    "OgreAtmosphere.dll",
    "OgreHlmsPbs.dll",
    "OgreHlmsUnlit.dll",
    "OgreMain.dll",
    "OgreOverlay.dll",
    "OgrePlanarReflections.dll",
    "OpenAL32.dll",
    "Plugin_ParticleFX.dll",
    "RenderSystem_GL3Plus.dll",
    "RenderSystem_Vulkan.dll",
    "SDL2.dll",
    "amd_ags_x64.dll"
)

if ($IncludeDirect3D11) {
    $dlls += "RenderSystem_Direct3D11.dll"
}

$missing = New-Object System.Collections.Generic.List[string]

foreach ($dll in $dlls) {
    $sourceFile = Join-Path $sourcePath $dll
    $targetFile = Join-Path $runtimePath $dll
    if (-not (Test-Path -LiteralPath $sourceFile -PathType Leaf)) {
        $missing.Add($dll)
        continue
    }

    if ($PSCmdlet.ShouldProcess($targetFile, "Copy $dll from $sourcePath")) {
        Copy-Item -LiteralPath $sourceFile -Destination $targetFile -Force
    }
}

if ($missing.Count -gt 0) {
    $missing | ForEach-Object { [Console]::Error.WriteLine("Missing source DLL: $_") }
    exit 1
}

Write-Host "Runtime DLL staging complete: $runtimePath"
