[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$RuntimeDir = "",

    [Parameter(Mandatory = $false)]
    [switch]$RequireDirect3D11
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

function Add-Failure {
    param([string]$Message)
    $script:failures.Add($Message)
}

$runtimePath = Resolve-FullPath $RuntimeDir
$failures = New-Object System.Collections.Generic.List[string]

if (-not (Test-Path -LiteralPath $runtimePath -PathType Container)) {
    throw "RuntimeDir not found: $runtimePath"
}

$requiredFiles = @(
    "StuntRally3.exe",
    "SR-Editor3.exe",
    "plugins.cfg",
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

if ($RequireDirect3D11) {
    $requiredFiles += "RenderSystem_Direct3D11.dll"
}

foreach ($file in $requiredFiles) {
    $path = Join-Path $runtimePath $file
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        Add-Failure "Missing required runtime file: $file"
    }
}

$pluginsPath = Join-Path $runtimePath "plugins.cfg"
if (Test-Path -LiteralPath $pluginsPath -PathType Leaf) {
    $plugins = Get-Content -LiteralPath $pluginsPath
    $requiredPluginLines = @(
        "PluginOptional=RenderSystem_GL3Plus",
        "PluginOptional=RenderSystem_Vulkan",
        "Plugin=Plugin_ParticleFX"
    )

    foreach ($line in $requiredPluginLines) {
        if (-not ($plugins -contains $line)) {
            Add-Failure "plugins.cfg missing line: $line"
        }
    }

    if ($plugins -contains "PluginOptional=RenderSystem_Direct3D11" -and -not $RequireDirect3D11) {
        Write-Warning "Direct3D11 is enabled in plugins.cfg, but W0-W3 do not require it."
    }
} else {
    Add-Failure "Cannot validate plugins.cfg because it is missing."
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { [Console]::Error.WriteLine($_) }
    exit 1
}

Write-Host "Runtime bundle OK: $runtimePath"
