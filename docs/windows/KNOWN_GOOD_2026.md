# Stunt Rally 3 Windows Known-Good 2026

This document is the frozen record of the Windows build ritual once it has been reproduced in 2026.

Policy: Windows Build Rescue is reproducibility first, not modernization. Do not upgrade Ogre, replace renderers, redesign CMake, change gameplay, replace UI, or automate dependencies before a manual successful Windows source build exists.

## Status

- W0 packaged binary baseline: closed enough to proceed; screenshots remain a follow-up evidence improvement.
- W1 source build reproduction: SR3 Release x64 configure/generate succeeded; game/editor build succeeded; runtime staging and bundle validation succeeded; smoke not started.
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
- `$DEPS_ROOT`, `$OGRE_ROOT`, and `$MYGUI_ROOT` now exist.
- Ogre-Next, MyGUI-next, and non-Ogre SR3 dependency Release outputs exist.
- `docs/windows/evidence/W1/dependency-layout-plan.txt` records the full folder plan and current missing paths.
- `docs/windows/evidence/W1/deps-non-ogre-outputs.txt` records the verified non-Ogre dependency outputs.

W1 must freeze exact dependency paths and versions here after a successful source build.

## SR3 Release Configure

W1 verified the historical Windows Release configure route on 2026-04-30:

- Active route: `CMakeLists-WindowsRelease.txt` copied over `CMakeLists.txt`; `CMakeManual\*` copied over `CMake\*`; `bin\Release\plugins_Windows.cfg` copied over `bin\Release\plugins.cfg`.
- Source root: `C:\Games\stuntrally3-3.3\fork\stuntrally3-2026`.
- Build directory: `C:\Games\stuntrally3-3.3\fork\stuntrally3-2026\build-windows-release`.
- Generator and architecture: `Visual Studio 17 2022`, `x64`.
- CMake: VS2022 bundled CMake `3.31.6-msvc6`.
- Configure/generate result: success after one focused SDL2 configure-path fix.
- Generated solution: `build-windows-release\StuntRally3.sln`.

Configure-only W1 path variables:

```text
WBR_DEPS_ROOT = C:/dev
WBR_OGRE_ROOT = C:/dev/Ogre/ogre-next
WBR_MYGUI_ROOT = C:/dev/mygui-next
WBR_SKIP_CONFIGURE_DLL_COPY = ON
```

Verified configure-path notes:

- Historical `D:/_/sr`, `D:/_/sr/og3`, `C:/b/boost_1_81_0`, and `../og3/` assumptions are mapped to the W1 dependency roots above in active `CMakeLists.txt`.
- Ogre build root used by configure: `C:/dev/Ogre/ogre-next/build`.
- MyGUI library path used by configure: `C:/dev/mygui-next/build/lib/Release`.
- Boost library path used by configure: `C:/dev/boost_1_81_0-msvc-14.3/lib64-msvc-14.3`.
- `WBR_SKIP_CONFIGURE_DLL_COPY=ON` prevents the manual Ogre helper from staging runtime DLLs during configure.
- The first configure attempt failed because Ogre's SDL2 CMake package referenced a non-existent unconfigured `Dependencies/bin/SDL2.dll`; the successful retry uses verified Ogre deps SDL2 paths under `C:/dev/Ogre/ogre-next-deps`.

Build status:

- `StuntRally3.exe` built successfully from `build-windows-release\StuntRally3.sln`.
- `SR-Editor3.exe` built successfully from `build-windows-release\StuntRally3.sln`.
- Built executable path note: current generated output directory is `bin\Release\Release`, not historical runtime root `bin\Release`.
- Runtime staging and bundle validation succeeded.
- Smoke tests not run yet.

## SR3 Release Build

W1 verified the historical Windows Release build route on 2026-04-30:

- Build directory: `C:\Games\stuntrally3-3.3\fork\stuntrally3-2026\build-windows-release`.
- Solution: `build-windows-release\StuntRally3.sln`.
- Generator and architecture: `Visual Studio 17 2022`, `x64`.
- Toolchain: VS2022 Build Tools.
- CMake: VS2022 bundled CMake `3.31.6-msvc6`.
- Build command: `cmake --build "C:\Games\stuntrally3-3.3\fork\stuntrally3-2026\build-windows-release" --config Release --target StuntRally3 SR-Editor3 -- /m`.
- Build result: success, exit code `0`.
- Focused build fixes required: none.

Produced executables:

```text
C:\Games\stuntrally3-3.3\fork\stuntrally3-2026\bin\Release\Release\StuntRally3.exe  4248064 bytes
C:\Games\stuntrally3-3.3\fork\stuntrally3-2026\bin\Release\Release\SR-Editor3.exe    3037696 bytes
```

Build warnings observed but not fixed in W1:

- `warning C4244` from `src/road/Grid.cpp`.
- `warning C4005` for `M_PI`, `WINVER`, and `_WIN32_WINNT` macro redefinitions.

Not yet verified:

- Game/editor launch smoke.

## W1 Runtime Staging

W1 verified runtime staging and bundle validation on 2026-04-30:

- Runtime root: `C:\Games\stuntrally3-3.3\fork\stuntrally3-2026\bin\Release`.
- Staging approach: copied built executables from `bin\Release\Release` into the historical `bin\Release` runtime root.
- CMake output paths were not changed during staging.
- Runtime bundle validation: passed with `tools/windows/Test-WindowsRuntimeBundle.ps1`.
- Runtime manifest: `docs/windows/evidence/W1/runtime-manifest.csv`.

Staged executable files:

```text
C:\Games\stuntrally3-3.3\fork\stuntrally3-2026\bin\Release\StuntRally3.exe  4248064 bytes
C:\Games\stuntrally3-3.3\fork\stuntrally3-2026\bin\Release\SR-Editor3.exe    3037696 bytes
```

Staged DLL/config files:

```text
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

Runtime source notes:

- MyGUI DLL came from `C:\dev\mygui-next\build\bin\Release`.
- Ogre DLLs/plugins, `SDL2.dll`, and `amd_ags_x64.dll` came from `C:\dev\Ogre\ogre-next\build\bin\Release`.
- `OpenAL32.dll` came from `C:\dev\openal-soft-1.23.1\build\Release`.
- No files were copied from the preserved packaged binary specimen.
- `RenderSystem_Direct3D11.dll` was not staged because Direct3D11 is not a W0-W3 acceptance requirement.

Not yet verified:

- Game/editor launch smoke from the W1 runtime root.

## Dependency Versions

Starting point from `docs/BuildingVS.md`:

| Library | Upstream documented version | W1 reproduced version |
| --- | --- | --- |
| tinyxml2 | 9.0.0 | 9.0.0, git tag `9.0.0`, Release static lib built |
| Bullet | 3.25 | 3.25, git tag `3.25`, premake VS2010 output built with VS2022 `v143` override |
| Boost | 1.81 | 1.81.0, SourceForge `msvc-14.3` x64 binary package installed after source-build blocker |
| Enet | 1.3.17 | 1.3.17, git tag `v1.3.17`, Release static lib built |
| Ogg | 1.3.5 | 1.3.5, Xiph release archive, Release static lib built |
| Vorbis | 1.3.7 | 1.3.7, Xiph release archive, Release static libs built against Ogg install |
| OpenAL Soft | 1.23.1 | 1.23.1, git tag `1.23.1`, Release shared DLL/import lib built |
| Ogre-Next | 3.0 / branch `v3-0` | branch `v3-0`, commit `20da67178c571efe1c909db73b710698d60bf3b3` |
| MyGUI-next | branch `ogre3` | branch `ogre3`, commit `a1490ffe01d503c31a00d8277007ffcb27a4258e` |

## Ogre-Next Required Settings

W1 must verify and record:

- Ogre-Next branch: `v3-0`.
- Exact commit: `20da67178c571efe1c909db73b710698d60bf3b3`.
- Generator and architecture: `Visual Studio 17 2022`, `x64`, under VS2022 Build Tools.
- CMake: VS2022 bundled CMake `3.31.6-msvc6`.
- `OGRE_BUILD_COMPONENT_ATMOSPHERE:BOOL=1`.
- `OGRE_BUILD_COMPONENT_PLANAR_REFLECTIONS:BOOL=1`.
- Release configure/build/install result: success.
- Release runtime/plugins produced: `OgreMain.dll`, `OgreHlmsPbs.dll`, `OgreHlmsUnlit.dll`, `OgreAtmosphere.dll`, `OgrePlanarReflections.dll`, `Plugin_ParticleFX.dll`, `RenderSystem_GL3Plus.dll`, `RenderSystem_Vulkan.dll`, `RenderSystem_Direct3D11.dll`.
- Source patch status: no Ogre source patches. `Dependencies` path uses a directory junction because symlink creation was not permitted.

## MyGUI-next Required Settings

W1 must verify and record:

- MyGUI-next branch: `ogre3`.
- Exact commit: `a1490ffe01d503c31a00d8277007ffcb27a4258e`.
- Generator and architecture: `Visual Studio 17 2022`, `x64`, under VS2022 Build Tools.
- CMake: VS2022 bundled CMake `3.31.6-msvc6`.
- `MYGUI_RENDERSYSTEM:STRING=8`.
- `MYGUI_USE_FREETYPE:BOOL=ON`.
- `MYGUI_STATIC:BOOL=OFF`.
- `MYGUI_BUILD_DEMOS:BOOL=OFF`.
- `MYGUI_BUILD_PLUGINS:BOOL=OFF`.
- `MYGUI_BUILD_TEST_APP:BOOL=OFF`.
- `MYGUI_BUILD_TOOLS:BOOL=OFF`.
- `MYGUI_BUILD_UNITTESTS:BOOL=OFF`.
- `MYGUI_BUILD_WRAPPER:BOOL=OFF`.
- Release configure/build result: success after one focused Freetype/zlib link fix.
- Release outputs produced: `MyGUIEngine.dll`, `MyGUIEngine.lib`, `MyGUI.Ogre2Platform.lib`.
- Windows CMake replacements: `FindFreetype_Windows.cmake` copied over `FindFreetype.cmake`; `FindOGRE_next_WindowsRelease.cmake` copied over `FindOGRE_next.cmake`.
- Focused external dependency-tree fix: `FindFreetype.cmake` links Ogre deps Release `zlib.lib` with `freetype.lib`.

## Non-Ogre Dependency Outputs

W1 verified these Release x64 dependency roots and outputs under `C:\dev`:

- tinyxml2: `C:\dev\tinyxml2-9.0.0`; `build\Release\tinyxml2.lib`; `install\lib\tinyxml2.lib`; configured with `BUILD_SHARED_LIBS=OFF`.
- Bullet: `C:\dev\bullet3-3.25`; `bin\BulletCollision_vs2010_x64_release.lib`, `BulletDynamics_vs2010_x64_release.lib`, `BulletFileLoader_vs2010_x64_release.lib`, `BulletWorldImporter_vs2010_x64_release.lib`, and `LinearMath_vs2010_x64_release.lib`; premake used `--dynamic-runtime` and did not use `--double`.
- Boost: `C:\dev\boost_1_81_0-msvc-14.3`; selected VS2022/v143 candidate libs are under `lib64-msvc-14.3`, including `boost_system-vc143-mt-x64-1_81.lib`, `boost_thread-vc143-mt-x64-1_81.lib`, `libboost_system-vc143-mt-x64-1_81.lib`, and `libboost_thread-vc143-mt-x64-1_81.lib`.
- ENet: `C:\dev\enet-1.3.17`; `build\Release\enet.lib`; no install target was generated.
- Ogg: `C:\dev\libogg-1.3.5`; `build\Release\ogg.lib`; `install\lib\ogg.lib`; configured with `BUILD_SHARED_LIBS=OFF`.
- Vorbis: `C:\dev\libvorbis-1.3.7`; `build\lib\Release\vorbis.lib`; `build\lib\Release\vorbisfile.lib`; configured with `CMAKE_PREFIX_PATH` and `OGG_ROOT` pointing to `C:\dev\libogg-1.3.5\install`.
- OpenAL Soft: `C:\dev\openal-soft-1.23.1`; `build\Release\OpenAL32.dll`; `build\Release\OpenAL32.lib`; install copies under `install\bin` and `install\lib`; configured with `LIBTYPE=SHARED`.

Runtime/linkage notes verified during W1:

- CMake/VS Release dependency builds use the Visual Studio Release `/MD` runtime model unless later SR3 link evidence proves otherwise.
- Bullet compile output explicitly shows `/MD`.
- Boost source build with `runtime-link=shared` failed before producing libraries; the installed `msvc-14.3` package contains multiple variants, and the non-suffixed `vc143-mt-x64` libraries are the current SR3 configure candidates.
- ENet consumers may still need `winmm.lib` and `Ws2_32.lib` at the SR3 link step, as noted by `docs/BuildingVS.md`.

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
