# Stunt Rally 3 Windows Known-Good 2026

This document is the frozen record of the Windows build ritual once it has been reproduced in 2026.

Policy: Windows Build Rescue is reproducibility first, not modernization. Do not upgrade Ogre, replace renderers, redesign CMake, change gameplay, replace UI, or automate dependencies before a manual successful Windows source build exists.

## Status

- W0 packaged binary baseline: closed enough to proceed; screenshots remain a follow-up evidence improvement.
- W1 source build reproduction: started.
- Primary target: Windows 11, Release x64.
- Primary renderer acceptance path: OpenGL 3+.
- Secondary useful evidence: Vulkan plugin/device enumeration.
- Direct3D11: out of scope for W0-W3.

## Doctrine

- `docs/BuildingVS.md` is the upstream ritual.
- `docs/windows/KNOWN_GOOD_2026.md` is the successful reproduced ritual.
- `docs/windows/WINDOWS_BUILD_RESCUE.md` is the evidence log.
- `tools/windows/*.ps1` are guardrails, not magic.

## W0 Packaged Binary Baseline

Current packaged runtime root:

```text
$PACKAGE_ROOT = $SR3_ROOT\windows binaries\Stunt Rally 3.3
$RUNTIME_DIR  = $PACKAGE_ROOT\bin\Release
$USER_CONFIG  = C:\Users\julie\AppData\Roaming\stuntrally3
```

Current evidence files:

```text
docs/windows/evidence/W0/runtime-manifest.csv
docs/windows/evidence/W0/runtime-bundle-report.txt
docs/windows/evidence/W0/logs/
docs/windows/evidence/W0/config/
```

W0 remains open until screenshots are attached and the baseline is reviewed as a complete known-good artifact.

## Toolchain Record

W1 must fill this section from the machine that successfully reproduces the build.

```text
Windows version: Windows 11 Home 10.0.26200 build 26200, 64-bit
CPU: AMD Ryzen 7 7700 8-Core Processor, 8 cores / 16 logical processors
GPU: NVIDIA GeForce RTX 4070 SUPER driver 32.0.15.9186; AMD Radeon(TM) Graphics driver 32.0.12011.1036
Visual Studio version: VS2022 Build Tools 17.14.37027.9 first; VS2026 Build Tools 18.4.11612.150 also installed
MSVC toolset: VS2022 14.44.35207 / compiler 19.44.35224 first; VS2026 14.50.35717 / compiler 19.50.35727 available
Windows SDK: 10.0.26100.0
CMake: not on normal PATH; VS2022 bundled CMake 3.31.6-msvc6; VS2026 bundled CMake 4.2.3-msvc3
Git: 2.53.0.windows.2
PowerShell: 7.6.0
```

W1 rule: try Visual Studio 2022 first. If Ogre/MyGUI/SR3 dependency friction exceeds one focused pass, fall back to Visual Studio 2019 and document the blocker here.

## Dependency Layout

Use replaceable variables in documentation and scripts.

```text
$SPECIMEN_ROOT = C:\Games\stuntrally3-3.3
$PACKAGE_ROOT  = $SPECIMEN_ROOT\windows binaries\Stunt Rally 3.3
$SR3_ROOT      = C:\Games\stuntrally3-3.3\fork\stuntrally3-2026
$DEPS_ROOT     = C:\dev
$OGRE_ROOT     = $DEPS_ROOT\Ogre\ogre-next
$MYGUI_ROOT    = $DEPS_ROOT\mygui-next
```

W1 layout pass status:

- `$SPECIMEN_ROOT` exists and remains the preserved binary/audit parent.
- `$PACKAGE_ROOT` exists and remains the known-good packaged binary specimen.
- `$SR3_ROOT` exists and is the clean Git source fork for source-build reproduction.
- `$DEPS_ROOT`, `$OGRE_ROOT`, and `$MYGUI_ROOT` are planned but currently missing.
- `docs/windows/evidence/W1/dependency-layout-plan.txt` records the full folder plan and current missing paths.

W1 must freeze exact dependency paths and versions here after a successful source build.

## Dependency Versions

Starting point from `docs/BuildingVS.md`:

| Library | Upstream documented version | W1 reproduced version |
| --- | --- | --- |
| tinyxml2 | 9.0.0 | TBD |
| Bullet | 3.25 | TBD |
| Boost | 1.81 | TBD |
| Enet | 1.3.17 | TBD |
| Ogg | 1.3.5 | TBD |
| Vorbis | 1.3.7 | TBD |
| OpenAL Soft | 1.23.1 | TBD |
| Ogre-Next | 3.0 / branch `v3-0` | TBD |
| MyGUI-next | branch `ogre3` | TBD |

## Ogre-Next Required Settings

W1 must verify and record:

- Ogre-Next branch.
- Exact commit.
- Generator and architecture.
- `OGRE_BUILD_COMPONENT_ATMOSPHERE=ON`.
- `OGRE_BUILD_COMPONENT_PLANAR_REFLECTIONS=ON`.
- Render systems built and staged.
- Any source patches or debug-only assert changes.

## MyGUI-next Required Settings

W1 must verify and record:

- MyGUI-next branch.
- Exact commit.
- `MYGUI_RENDERSYSTEM=8 - Ogre 3.x`.
- `MYGUI_USE_FREETYPE=ON`.
- `MYGUI_STATIC=OFF`.
- Which CMake files had to be renamed or edited.

## Runtime Bundle Contract

Release runtime must include:

```text
StuntRally3.exe
SR-Editor3.exe
plugins.cfg
MyGUIEngine.dll
OgreAtmosphere.dll
OgreHlmsPbs.dll
OgreHlmsUnlit.dll
OgreMain.dll
OgreOverlay.dll
OgrePlanarReflections.dll
OpenAL32.dll
Plugin_ParticleFX.dll
RenderSystem_GL3Plus.dll
RenderSystem_Vulkan.dll
SDL2.dll
amd_ags_x64.dll
```

`RenderSystem_Direct3D11.dll` may be present in the historical packaged runtime, but it is not an acceptance requirement for W0-W3.

`plugins.cfg` must load:

```text
PluginOptional=RenderSystem_GL3Plus
PluginOptional=RenderSystem_Vulkan
Plugin=Plugin_ParticleFX
```

## Smoke Acceptance

W0 packaged baseline evidence currently records:

- Game and editor logs were present under `%APPDATA%\stuntrally3`.
- Game log loaded GL3Plus, Vulkan, and ParticleFX plugins.
- Game log enumerated `NVIDIA GeForce RTX 4070 SUPER` and `AMD Radeon(TM) Graphics` as Vulkan devices.
- Editor log created an OpenGL 3+ renderer on `NVIDIA GeForce RTX 4070 SUPER/PCIe/SSE2`.

W1 source build acceptance requires:

```powershell
tools/windows/Test-WindowsRuntimeBundle.ps1 -RuntimeDir "$SR3_ROOT\bin\Release"
tools/windows/Start-WindowsSmoke.ps1 -RuntimeDir "$SR3_ROOT\bin\Release" -RunEditor
tools/windows/Get-WindowsRuntimeManifest.ps1 -RuntimeDir "$SR3_ROOT\bin\Release" -OutputPath docs/windows/evidence/W1/runtime-manifest.csv
```
