[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$Sr3Root = "",

    [Parameter(Mandatory = $false)]
    [string]$DepsRoot = "C:\dev",

    [Parameter(Mandatory = $false)]
    [string]$OgreRoot,

    [Parameter(Mandatory = $false)]
    [string]$MyGuiRoot,

    [Parameter(Mandatory = $false)]
    [string]$Configuration = "Release"
)

$ErrorActionPreference = "Stop"

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $Sr3Root) {
    $Sr3Root = Join-Path $scriptRoot "..\.."
}

function Resolve-FullPath {
    param([string]$Path)
    if ([System.IO.Path]::IsPathRooted($Path)) {
        return [System.IO.Path]::GetFullPath($Path)
    }
    return [System.IO.Path]::GetFullPath((Join-Path (Get-Location) $Path))
}

function Test-RequiredPath {
    param(
        [string]$Path,
        [string]$Description,
        [ValidateSet("Any", "Container", "Leaf")]
        [string]$Type = "Any"
    )

    $exists = switch ($Type) {
        "Container" { Test-Path -LiteralPath $Path -PathType Container }
        "Leaf" { Test-Path -LiteralPath $Path -PathType Leaf }
        default { Test-Path -LiteralPath $Path }
    }

    if ($exists) {
        Write-Host "OK: $Description -> $Path"
    } else {
        $script:failures.Add("Missing $Description -> $Path")
    }
}

$sr3Path = Resolve-FullPath $Sr3Root
$depsPath = Resolve-FullPath $DepsRoot
if (-not $OgreRoot) {
    $OgreRoot = Join-Path $depsPath "Ogre\ogre-next"
}
if (-not $MyGuiRoot) {
    $MyGuiRoot = Join-Path $depsPath "mygui-next"
}

$ogrePath = Resolve-FullPath $OgreRoot
$myguiPath = Resolve-FullPath $MyGuiRoot
$failures = New-Object System.Collections.Generic.List[string]

Test-RequiredPath -Path $sr3Path -Description "SR3 root" -Type Container
Test-RequiredPath -Path (Join-Path $sr3Path "docs\BuildingVS.md") -Description "upstream Windows ritual" -Type Leaf
Test-RequiredPath -Path (Join-Path $sr3Path "CMakeLists-WindowsRelease.txt") -Description "historical Windows release CMake" -Type Leaf
Test-RequiredPath -Path (Join-Path $sr3Path "bin\$Configuration\plugins_Windows.cfg") -Description "historical Windows plugins config" -Type Leaf
Test-RequiredPath -Path (Join-Path $sr3Path "data") -Description "SR3 data directory" -Type Container
Test-RequiredPath -Path $depsPath -Description "dependency root" -Type Container
Test-RequiredPath -Path $ogrePath -Description "Ogre-Next root" -Type Container
Test-RequiredPath -Path (Join-Path $ogrePath "build\bin\$Configuration") -Description "Ogre-Next runtime output" -Type Container
Test-RequiredPath -Path $myguiPath -Description "MyGUI-next root" -Type Container
Test-RequiredPath -Path (Join-Path $myguiPath "build") -Description "MyGUI-next build directory" -Type Container

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { [Console]::Error.WriteLine($_) }
    exit 1
}

Write-Host "Windows build layout OK."
