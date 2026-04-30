# Windows Build Rescue

Goal: make Stunt Rally 3 buildable, verifiable, and approachable on Windows in 2026.

Non-goals: redesign the game, change renderer policy, alter gameplay, replace UI, automate dependencies before a manual successful build exists, upgrade Ogre, or perform broad CMake modernization.

## Policy

Windows Build Rescue is reproducibility first. The first win is a deterministic, documented, repeatable Windows build and runtime bundle.

Core doctrine:

- `docs/BuildingVS.md` is the upstream ritual.
- `docs/windows/KNOWN_GOOD_2026.md` is the successful reproduced ritual.
- `docs/windows/WINDOWS_BUILD_RESCUE.md` is the evidence log.
- `tools/windows/*.ps1` are guardrails, not magic.

## Milestone Status

| Milestone | Status | Closure rule |
| --- | --- | --- |
| W0 - Known-good Windows binary baseline | Closed enough to proceed | Hashes, logs, config snapshots, DLL/plugin manifest, and smoke notes are present in repo form; screenshots remain a follow-up evidence improvement. |
| W1 - Reproduce existing Windows build manually once | Closed | Release x64 game and editor are built from source and launched from the built tree; launch evidence is initialization smoke with timeout caveat, not clean process-exit smoke. |
| W2 - Freeze blessed dependency layout | Ready | `KNOWN_GOOD_2026.md` can guide a maintainer through the successful layout without undocumented steps. |
| W3 - Script boring fragile parts | Started | Layout, runtime bundle, copy, smoke, manifest, and manifest comparison scripts work against known-good outputs. |
| W4 - Reduce manual dependency pain | Blocked by W1 | Conan/vcpkg/prebuilt-cache options are compared against the reproduced W1 layout. |
| W5 - CI or semi-CI Windows verification | Blocked by W3 | A fresh checkout can run validation and produce an artifact-structure report. |

## W0 Evidence Log

Date: 2026-04-30

Baseline source:

```text
C:\Games\stuntrally3-3.3\windows binaries\Stunt Rally 3.3
```

Runtime directory:

```text
C:\Games\stuntrally3-3.3\windows binaries\Stunt Rally 3.3\bin\Release
```

User config/log directory:

```text
C:\Users\julie\AppData\Roaming\stuntrally3
```

Evidence captured under:

```text
docs/windows/evidence/W0/
```

Current evidence items:

- Runtime SHA256/size manifest.
- Runtime bundle validation report.
- Smoke helper report from `Start-WindowsSmoke.ps1`.
- Packaged `plugins.cfg` snapshot.
- User config snapshots for game/editor Ogre config and game/editor config.
- Game/editor Ogre and MyGUI log snapshots.

Observed runtime signals from existing logs:

- Game log loads `RenderSystem_GL3Plus`, `RenderSystem_Vulkan`, and `Plugin_ParticleFX`.
- Game log enumerates Vulkan devices: `NVIDIA GeForce RTX 4070 SUPER` and `AMD Radeon(TM) Graphics`.
- Game log records Vulkan render-system capabilities for `NVIDIA GeForce RTX 4070 SUPER`.
- Editor log creates an OpenGL 3+ renderer and reports `GL_VERSION = 4.5.0 NVIDIA 591.86`.
- Editor log reports `RenderSystem Name: OpenGL 3+ Rendering Subsystem`.

Open W0 closure items:

- Attach at least one screenshot from game launch.
- Attach at least one screenshot from editor launch, if editor is part of W0 closure.
- Re-run smoke using `tools/windows/Start-WindowsSmoke.ps1` after any runtime-bundle changes. The first hidden-window `check` run timed out after 45 seconds and is recorded in `docs/windows/evidence/W0/smoke-report.txt`; previous good launch evidence remains preserved in the copied log snapshots.
- Review whether historical log exceptions are benign for baseline purposes or should be called out as known warnings.

## W1 Manual Reproduction Rules

Start from `docs/BuildingVS.md`.

Record every deviation in this file and then promote the final successful ritual into `KNOWN_GOOD_2026.md`.

Compiler policy:

- Try Visual Studio 2022 first.
- If Ogre/MyGUI/SR3 dependency friction exceeds one focused pass, fall back to Visual Studio 2019.
- Document the exact blocker before falling back.

Renderer policy:

- OpenGL 3+ is the primary acceptance path.
- Vulkan plugin/device evidence is useful.
- Direct3D11 remains out of scope for W0-W3.

## W1 Task Checklist

Date started: 2026-04-30

Evidence directory:

```text
docs/windows/evidence/W1/
```

Checklist:

- [x] Detect installed Windows version, CPU, GPU, Git, PowerShell, Visual Studio instances, MSVC toolsets, Windows SDKs, MSBuild, and CMake availability.
- [x] Record that plain shell `cmake` is not on PATH; bundled CMake exists inside Visual Studio developer environments.
- [x] Choose the first W1 compiler lane: VS2022 Build Tools unless the first focused dependency pass proves it too costly.
- [x] Confirm planned source/specimen/dependency layout and capture current missing dependency folders.
- [x] Download/clone/build dependencies following `docs/BuildingVS.md` before attempting any package-manager replacement. Ogre-next-deps and non-Ogre SR3 dependencies are now reproduced or documented.
- [x] Build Ogre-Next branch `v3-0` with Atmosphere and Planar Reflections enabled.
- [x] Build MyGUI-next branch `ogre3` against the reproduced Ogre-Next output.
- [x] Configure SR3 Release x64 using the historical Windows release CMake route, documenting every path edit or file rename.
- [x] Build `StuntRally3.exe` and `SR-Editor3.exe`.
- [x] Stage runtime DLLs and `plugins.cfg` using the W3 scripts where possible.
- [x] Validate the built runtime bundle, generate a W1 manifest, and run launch smoke.
- [x] Promote the final successful machine/toolchain/dependency layout into `KNOWN_GOOD_2026.md`.

W1 closure verdict:

- W1 is closed on 2026-04-30.
- Source-built `StuntRally3.exe` and `SR-Editor3.exe` were configured, built, staged, validated, and launched from the W1 runtime root.
- Runtime bundle validation passed before smoke.
- Both executables initialized far enough to write fresh Ogre logs, load GL3Plus/Vulkan/ParticleFX, and enumerate GPUs.
- The smoke helper timed out after 45 seconds and killed both processes, so the evidence is launch-initialization smoke rather than clean process-exit smoke.
- No missing DLL, plugin, or config blocker remains in W1 evidence.

Moved out of W1 closure:

- Visible screenshot evidence.
- Clean-exit smoke helper improvement.
- Optional forced OpenGL game smoke/screenshot.
- Output path cleanup for generated `bin\Release\Release` executables.
- Dependency pain reduction, packaging automation, or CI/semi-CI validation.

### W1 Machine Detection Snapshot

Full captured evidence:

```text
docs/windows/evidence/W1/toolchain-detection.txt
```

Detected on 2026-04-30:

- Windows: Windows 11 Home, version `10.0.26200`, build `26200`, 64-bit.
- CPU: AMD Ryzen 7 7700 8-Core Processor, 8 cores / 16 logical processors.
- GPUs: NVIDIA GeForce RTX 4070 SUPER, driver `32.0.15.9186`; AMD Radeon(TM) Graphics, driver `32.0.12011.1036`.
- Git: `2.53.0.windows.2`.
- PowerShell: `7.6.0`.
- Windows SDK: `10.0.26100.0`.
- CMake on normal PATH: not found.
- VS2022 Build Tools: installed at `C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools`, version `17.14.37027.9`; MSVC toolset `14.44.35207`, compiler `19.44.35224`; MSBuild `17.14.40.60911`; bundled CMake `3.31.6-msvc6`.
- VS2026 Build Tools: installed at `C:\Program Files (x86)\Microsoft Visual Studio\18\BuildTools`, version `18.4.11612.150`; MSVC toolset `14.50.35717`, compiler `19.50.35727`; MSBuild `18.4.0.7901`; bundled CMake `4.2.3-msvc3`.

Initial W1 lane decision:

- Use VS2022 Build Tools first because it is closer to the upstream VS2019 ritual than VS2026.
- Use the VS2022 developer environment to access bundled CMake unless a standalone CMake install is added deliberately and documented.
- If Ogre/MyGUI/SR3 dependency friction exceeds one focused pass under VS2022, document the blocker and fall back toward VS2019 compatibility instead of drifting into compiler modernization.

### W1 Dependency Layout Evidence

Full captured evidence:

```text
docs/windows/evidence/W1/dependency-layout-plan.txt
docs/windows/evidence/W1/build-layout-check.txt
```

Detected/planned layout:

- Specimen/audit parent: `C:\Games\stuntrally3-3.3`.
- Preserved packaged binary: `C:\Games\stuntrally3-3.3\windows binaries\Stunt Rally 3.3`.
- Clean source fork for W1 source-build work: `C:\Games\stuntrally3-3.3\fork\stuntrally3-2026`.
- Dependency root: `C:\dev`.
- Ogre-Next root: `C:\dev\Ogre\ogre-next`.
- MyGUI-next root: `C:\dev\mygui-next`.

Correction recorded: `$SR3_ROOT` for W1 source-build work should mean the clean source fork, not the specimen/audit parent. Use `$SPECIMEN_ROOT` for `C:\Games\stuntrally3-3.3` when referring to the external preserved binary context.

Layout checker result:

- Expected failure because no dependency root has been created yet.
- Source fork checks passed: `docs/BuildingVS.md`, `CMakeLists-WindowsRelease.txt`, `bin\Release\plugins_Windows.cfg`, and `data`.
- Missing dependency paths: `C:\dev`, `C:\dev\Ogre\ogre-next`, `C:\dev\Ogre\ogre-next\build\bin\Release`, `C:\dev\mygui-next`, and `C:\dev\mygui-next\build`.

Upstream ritual mismatches to carry into the next pass:

- `docs/BuildingVS.md` uses `C:\dev` examples, but `CMakeLists-WindowsRelease.txt` still contains historical `D:/_/sr/...`, `D:/_/sr/og3/...`, and `C:/b/boost_1_81_0` paths.
- `CMakeLists-WindowsRelease.txt` sets `DIR_ONE_ABOVE` to `../og3/`, which does not match the planned `C:\dev` layout without path edits or a compatibility folder.
- Boost is documented as a VS2019 `msvc-14.2` binary package; VS2022 first lane uses MSVC 14.44, so Boost binary compatibility remains unresolved.
- The Ogre-Next build script named in the upstream ritual is VS2019-specific; use VS2022 first, but document the blocker and fall back if this becomes compiler modernization.

Next recommended W1 step:

- Create or confirm `C:\dev`, then begin the Ogre-Next reproduction pass only: fetch the upstream Ogre VS build script, pin branch `v3-0`, apply only the documented Planar Reflections setting, run under the VS2022 developer environment, and capture all deviations. Do not start MyGUI or SR3 until Ogre-Next output exists and is documented.

### W1 Ogre-Next Reproduction Evidence

Full captured evidence:

```text
docs/windows/evidence/W1/ogre-fetch.txt
docs/windows/evidence/W1/ogre-branch-commit.txt
docs/windows/evidence/W1/ogre-configure-command.txt
docs/windows/evidence/W1/ogre-configure-output.txt
docs/windows/evidence/W1/ogre-cache-summary.txt
docs/windows/evidence/W1/ogre-build-command.txt
docs/windows/evidence/W1/ogre-build-output.txt
docs/windows/evidence/W1/ogre-install-output.txt
docs/windows/evidence/W1/ogre-build-result.txt
docs/windows/evidence/W1/ogre-deviations.txt
```

Result:

- `C:\dev` created.
- Upstream Ogre VS2019 script downloaded and preserved at `C:\dev\build_ogre_Visual_Studio_16_2019_x64.bat`.
- Ogre-next-deps cloned, configured, built, and installed for Debug and Release.
- Ogre-Next cloned to `C:\dev\Ogre\ogre-next`.
- Ogre-Next branch: `v3-0`.
- Ogre-Next commit: `20da67178c571efe1c909db73b710698d60bf3b3` (`20da67178c Merge branch 'v2-3' into v3-0`).
- Generator/toolchain: VS2022 developer environment, `Visual Studio 17 2022`, platform `x64`, bundled CMake `3.31.6-msvc6`.
- Configure result: success.
- Release build result: success.
- Release install result: success.

Required Ogre settings verified in `C:\dev\Ogre\ogre-next\build\CMakeCache.txt`:

- `OGRE_BUILD_COMPONENT_ATMOSPHERE:BOOL=1`.
- `OGRE_BUILD_COMPONENT_PLANAR_REFLECTIONS:BOOL=1`.

Produced Release runtime/plugin DLLs include:

- `OgreMain.dll`
- `OgreHlmsPbs.dll`
- `OgreHlmsUnlit.dll`
- `OgreAtmosphere.dll`
- `OgrePlanarReflections.dll`
- `Plugin_ParticleFX.dll`
- `RenderSystem_GL3Plus.dll`
- `RenderSystem_Vulkan.dll`
- `RenderSystem_Direct3D11.dll`

Recorded deviations:

- The upstream script is VS2019-named and assumes generator `Visual Studio 16 2019`; W1 used `Visual Studio 17 2022` because VS2022 is the selected first lane.
- The upstream script assumes standalone CMake; W1 used VS2022 bundled CMake because plain-shell CMake is not on PATH.
- `mklink /D Dependencies ...` failed due to missing symlink privilege; W1 used `mklink /J` directory junction for the same target path.
- `OGRE_BUILD_COMPONENT_ATMOSPHERE=1` was set explicitly along with the documented Planar Reflections setting so both SR3-required components are cache-verifiable.

Next recommended W1 step:

- Begin MyGUI-next reproduction only: clone `https://github.com/cryham/mygui-next` branch `ogre3`, configure it against the verified Ogre-Next output at `C:\dev\Ogre\ogre-next`, capture the exact CMake settings/deviations, and stop after MyGUI build evidence. Do not configure or build SR3 yet.

### W1 MyGUI-next Reproduction Evidence

Full captured evidence:

```text
docs/windows/evidence/W1/mygui-fetch.txt
docs/windows/evidence/W1/mygui-branch-commit.txt
docs/windows/evidence/W1/mygui-configure-command.txt
docs/windows/evidence/W1/mygui-configure-output.txt
docs/windows/evidence/W1/mygui-cache-summary.txt
docs/windows/evidence/W1/mygui-build-command.txt
docs/windows/evidence/W1/mygui-build-output-first-failed.txt
docs/windows/evidence/W1/mygui-build-output.txt
docs/windows/evidence/W1/mygui-build-result.txt
docs/windows/evidence/W1/mygui-renames-edits.txt
docs/windows/evidence/W1/mygui-deviations.txt
docs/windows/evidence/W1/build-layout-check-after-mygui.txt
```

Result:

- MyGUI-next cloned to `C:\dev\mygui-next`.
- MyGUI branch: `ogre3`.
- MyGUI commit: `a1490ffe01d503c31a00d8277007ffcb27a4258e` (`a1490ffe0 unique_ptr not auto_ptr`).
- Generator/toolchain: VS2022 developer environment, `Visual Studio 17 2022`, platform `x64`, bundled CMake `3.31.6-msvc6`.
- Configure result: success with a non-fatal `compiled OGRE DLL's wasn't found` warning.
- First Release build result: failed on unresolved zlib symbols from `freetype.lib`.
- Focused fix: added Ogre deps Release `zlib.lib` to the Windows `FindFreetype.cmake` library list.
- Retry Release build result: success.
- Install/staging: no install target run; MyGUI README defines Windows success as generated DLL/lib outputs.

Required MyGUI settings verified in `C:\dev\mygui-next\build\CMakeCache.txt`:

- `MYGUI_RENDERSYSTEM:STRING=8`.
- `MYGUI_USE_FREETYPE:BOOL=ON`.
- `MYGUI_STATIC:BOOL=OFF`.
- `MYGUI_BUILD_DEMOS:BOOL=OFF`.
- `MYGUI_BUILD_PLUGINS:BOOL=OFF`.
- `MYGUI_BUILD_TEST_APP:BOOL=OFF`.
- `MYGUI_BUILD_TOOLS:BOOL=OFF`.
- `MYGUI_BUILD_UNITTESTS:BOOL=OFF`.
- `MYGUI_BUILD_WRAPPER:BOOL=OFF`.

Produced Release outputs:

- `C:\dev\mygui-next\build\bin\Release\MyGUIEngine.dll`.
- `C:\dev\mygui-next\build\lib\Release\MyGUIEngine.lib`.
- `C:\dev\mygui-next\build\lib\Release\MyGUI.Ogre2Platform.lib`.

Layout checker result after MyGUI:

- Passed. `C:\dev`, Ogre-Next root/output, MyGUI root/build, and source fork checks are present.

Next recommended W1 step:

- Reproduce the remaining non-Ogre SR3 dependencies only: tinyxml2, Bullet, Boost, Enet, Ogg, Vorbis, and OpenAL Soft. Do not configure SR3 until those dependency roots/build outputs are present and documented.

### W1 Non-Ogre Dependency Reproduction Evidence

Full captured evidence:

```text
docs/windows/evidence/W1/deps-non-ogre-plan.txt
docs/windows/evidence/W1/deps-non-ogre-fetch.txt
docs/windows/evidence/W1/deps-non-ogre-source-revisions.txt
docs/windows/evidence/W1/deps-non-ogre-build-commands.txt
docs/windows/evidence/W1/deps-non-ogre-outputs.txt
docs/windows/evidence/W1/deps-non-ogre-runtime-model.txt
docs/windows/evidence/W1/deps-non-ogre-deviations.txt
docs/windows/evidence/W1/tinyxml2-result.txt
docs/windows/evidence/W1/bullet-result.txt
docs/windows/evidence/W1/boost-result.txt
docs/windows/evidence/W1/enet-result.txt
docs/windows/evidence/W1/ogg-result.txt
docs/windows/evidence/W1/vorbis-result.txt
docs/windows/evidence/W1/openal-soft-result.txt
docs/windows/evidence/W1/build-layout-check-after-non-ogre-deps.txt
```

Result:

- tinyxml2 `9.0.0` cloned from tag `9.0.0`, configured with `BUILD_SHARED_LIBS=OFF`, and built Release x64.
- Bullet `3.25` cloned from tag `3.25`, generated with the upstream premake VS2010 path, built required Release x64 legacy-named libs, retained `--dynamic-runtime`, and removed `--double`.
- Boost `1.81.0` source build was attempted with `runtime-link=shared` but failed before producing libraries; the VS2022-compatible `boost_1_81_0-msvc-14.3-64.exe` binary package was downloaded and installed to `C:\dev\boost_1_81_0-msvc-14.3`.
- ENet `1.3.17` cloned from tag `v1.3.17`, configured with CMake, and built Release x64 `enet.lib`.
- Ogg `1.3.5` downloaded from the Xiph release archive, configured with `BUILD_SHARED_LIBS=OFF`, and built/installed Release x64 `ogg.lib`.
- Vorbis `1.3.7` downloaded from the Xiph release archive, configured against `C:\dev\libogg-1.3.5\install`, and built/installed Release x64 `vorbis.lib` and `vorbisfile.lib`.
- OpenAL Soft `1.23.1` cloned from tag `1.23.1`, configured with `LIBTYPE=SHARED`, and built/installed `OpenAL32.dll` and `OpenAL32.lib`.

Verified outputs include:

- `C:\dev\tinyxml2-9.0.0\build\Release\tinyxml2.lib`.
- `C:\dev\bullet3-3.25\bin\BulletCollision_vs2010_x64_release.lib`.
- `C:\dev\bullet3-3.25\bin\BulletDynamics_vs2010_x64_release.lib`.
- `C:\dev\bullet3-3.25\bin\BulletFileLoader_vs2010_x64_release.lib`.
- `C:\dev\bullet3-3.25\bin\BulletWorldImporter_vs2010_x64_release.lib`.
- `C:\dev\bullet3-3.25\bin\LinearMath_vs2010_x64_release.lib`.
- `C:\dev\boost_1_81_0-msvc-14.3\lib64-msvc-14.3\boost_system-vc143-mt-x64-1_81.lib`.
- `C:\dev\boost_1_81_0-msvc-14.3\lib64-msvc-14.3\boost_thread-vc143-mt-x64-1_81.lib`.
- `C:\dev\boost_1_81_0-msvc-14.3\lib64-msvc-14.3\libboost_system-vc143-mt-x64-1_81.lib`.
- `C:\dev\boost_1_81_0-msvc-14.3\lib64-msvc-14.3\libboost_thread-vc143-mt-x64-1_81.lib`.
- `C:\dev\enet-1.3.17\build\Release\enet.lib`.
- `C:\dev\libogg-1.3.5\build\Release\ogg.lib`.
- `C:\dev\libvorbis-1.3.7\build\lib\Release\vorbis.lib`.
- `C:\dev\libvorbis-1.3.7\build\lib\Release\vorbisfile.lib`.
- `C:\dev\openal-soft-1.23.1\build\Release\OpenAL32.dll`.
- `C:\dev\openal-soft-1.23.1\build\Release\OpenAL32.lib`.

Recorded deviations:

- VS2022 Build Tools and shell CMake were used instead of the upstream VS2019 CMake-Gui flow.
- ENet has no generated `INSTALL` target, so W1 recorded the Release build output in place.
- Bullet's first VS2022 build failed because premake generated `v100` projects; retry used `/p:PlatformToolset=v143` without editing generated files.
- Boost source build failed in the mixed VS2022/VS2026 environment while making the MSVC setup target; W1 used the Boost 1.81 `msvc-14.3` x64 binary package instead of the upstream VS2019 `msvc-14.2` package.

Layout checker result after non-Ogre dependencies:

- Passed for the current W1 guard scope. The checker validates source root, dependency root, Ogre output, and MyGUI output; the new non-Ogre evidence files record the additional dependency outputs.

Next recommended W1 step:

- Begin the SR3 configure pass only: prepare the historical Windows Release CMake route in the source fork, map the hardcoded `D:/_/sr`, `D:/_/sr/og3`, `C:/b/boost_1_81_0`, and `DIR_ONE_ABOVE` assumptions to the verified W1 dependency roots, record every file rename/path edit, configure Release x64, and stop before broad CMake cleanup or dependency automation.

### W1 SR3 Release Configure Evidence

Full captured evidence:

```text
docs/windows/evidence/W1/sr3-configure-plan.txt
docs/windows/evidence/W1/sr3-renames-edits.txt
docs/windows/evidence/W1/sr3-active-route-diff.patch
docs/windows/evidence/W1/sr3-dependency-paths.txt
docs/windows/evidence/W1/sr3-configure-command.txt
docs/windows/evidence/W1/sr3-configure-output.txt
docs/windows/evidence/W1/sr3-cache-summary.txt
docs/windows/evidence/W1/sr3-configure-result.txt
docs/windows/evidence/W1/sr3-deviations.txt
```

Result:

- The historical Windows Release route was prepared in the source fork.
- `CMakeLists-WindowsRelease.txt` was copied over active `CMakeLists.txt`.
- `bin\Release\plugins_Windows.cfg` was copied over active `bin\Release\plugins.cfg`.
- `CMakeManual\*` was copied over active `CMake\*` so `CMake/Dependencies/OGRE.cmake` and other manual-route modules resolve.
- Previous active `CMakeLists.txt` and `plugins.cfg` snapshots were preserved as evidence only.
- Hardcoded historical paths were mapped to verified W1 roots under `C:\dev`.
- Build directory: `build-windows-release`.
- Generator/toolchain: VS2022 developer environment, `Visual Studio 17 2022`, platform `x64`, bundled CMake `3.31.6-msvc6`.

First configure attempt:

- Failed before generation because Ogre's `Dependencies` SDL2 CMake package referenced `C:/dev/Ogre/ogre-next/Dependencies/bin/SDL2.dll`, while the reproduced Ogre deps layout contains configuration-specific DLLs under `bin/Release`, `bin/Debug`, and `bin/RelWithDebInfo`.

Focused configure fixes:

- Added `WBR_SKIP_CONFIGURE_DLL_COPY=ON` and a guard in `CMake/Dependencies/OGRE.cmake` so this configure-only pass does not stage Ogre runtime DLLs into `bin\Release`.
- Under `WBR_DEPS_ROOT`, `CMake/Dependencies/OGRE.cmake` uses the verified Ogre deps SDL2 include path instead of the stale `find_package(SDL2)` package metadata.

Retry configure result:

- Configure: success.
- Generate: success.
- Generated solution: `build-windows-release\StuntRally3.sln`.
- Cache summary records `CMAKE_GENERATOR=Visual Studio 17 2022`, `CMAKE_GENERATOR_PLATFORM=x64`, `StuntRally3_SOURCE_DIR`, `StuntRally3_BINARY_DIR`, `OGRE_BINARIES=C:/dev/Ogre/ogre-next//build`, and all `WBR_*` roots.

Not performed:

- `StuntRally3.exe` was not built.
- `SR-Editor3.exe` was not built.
- Runtime DLL staging was not performed.
- Smoke tests were not run.

Next recommended W1 step:

- Begin the SR3 build pass only: build `StuntRally3.exe` and `SR-Editor3.exe` from `build-windows-release\StuntRally3.sln` in Release x64, capture build output, make only focused link/compile fixes if necessary, and stop before runtime staging or smoke tests.

### W1 SR3 Release Build Evidence

Full captured evidence:

```text
docs/windows/evidence/W1/sr3-build-command.txt
docs/windows/evidence/W1/sr3-build-output.txt
docs/windows/evidence/W1/sr3-build-result.txt
docs/windows/evidence/W1/sr3-build-errors.txt
docs/windows/evidence/W1/sr3-build-fixes.txt
docs/windows/evidence/W1/sr3-build-outputs.txt
docs/windows/evidence/W1/sr3-build-deviations.txt
```

Result:

- Build command was run from the VS2022 developer shell.
- Build directory: `build-windows-release`.
- Build command: `cmake --build ... --config Release --target StuntRally3 SR-Editor3 -- /m`.
- Target `StuntRally3`: success.
- Target `SR-Editor3`: success.
- Build exit code: `0`.
- No source or CMake fixes were needed during the build pass.

Produced executables:

- `C:\Games\stuntrally3-3.3\fork\stuntrally3-2026\bin\Release\Release\StuntRally3.exe` (`4248064` bytes).
- `C:\Games\stuntrally3-3.3\fork\stuntrally3-2026\bin\Release\Release\SR-Editor3.exe` (`3037696` bytes).

Observed warnings:

- `warning C4244` from MSVC tuple instantiation while compiling `src/road/Grid.cpp`.
- `warning C4005` for `M_PI` macro redefinition while compiling `src/vdrift/game.cpp`.
- `warning C4005` for `WINVER` and `_WIN32_WINNT` macro redefinition while compiling the editor precompiled header.

Not performed:

- Runtime DLL staging was not performed.
- `StuntRally3.exe` was not launched.
- `SR-Editor3.exe` was not launched.
- Smoke tests were not run.

Next recommended W1 step:

- Begin the runtime staging pass only: decide whether to stage against the produced `bin\Release\Release` executable location or make a focused output-path correction to match the historical `bin\Release` runtime directory, copy only the documented W1 DLL/plugin set, validate with `Test-WindowsRuntimeBundle.ps1`, generate a W1 runtime manifest, and stop before launch smoke unless explicitly asked.

### W1 Runtime Staging And Bundle Validation Evidence

Full captured evidence:

```text
docs/windows/evidence/W1/runtime-staging-plan.txt
docs/windows/evidence/W1/runtime-staging-command.txt
docs/windows/evidence/W1/runtime-staging-output.txt
docs/windows/evidence/W1/runtime-bundle-report.txt
docs/windows/evidence/W1/runtime-manifest.csv
docs/windows/evidence/W1/runtime-manifest-diff-vs-w0.txt
docs/windows/evidence/W1/runtime-staging-result.txt
docs/windows/evidence/W1/runtime-staging-deviations.txt
```

Result:

- Runtime root chosen: `C:\Games\stuntrally3-3.3\fork\stuntrally3-2026\bin\Release`.
- Built executables were copied from `bin\Release\Release` into the historical `bin\Release` runtime root.
- Required DLLs were staged from verified W1 dependency outputs.
- Existing historical `plugins.cfg` in `bin\Release` was retained and validated.
- `tools/windows/Test-WindowsRuntimeBundle.ps1` passed.
- W1 runtime manifest was generated.
- No game/editor launch or smoke test was run.

Required runtime files validated:

- `StuntRally3.exe`.
- `SR-Editor3.exe`.
- `plugins.cfg`.
- `MyGUIEngine.dll`.
- `OgreAtmosphere.dll`.
- `OgreHlmsPbs.dll`.
- `OgreHlmsUnlit.dll`.
- `OgreMain.dll`.
- `OgreOverlay.dll`.
- `OgrePlanarReflections.dll`.
- `OpenAL32.dll`.
- `Plugin_ParticleFX.dll`.
- `RenderSystem_GL3Plus.dll`.
- `RenderSystem_Vulkan.dll`.
- `SDL2.dll`.
- `amd_ags_x64.dll`.

Dependency/runtime source notes:

- `amd_ags_x64.dll` was copied from `C:\dev\Ogre\ogre-next\build\bin\Release`, not from the preserved packaged specimen.
- No files were copied from the preserved packaged binary specimen.
- `RenderSystem_Direct3D11.dll` was not staged and is not a W0-W3 acceptance requirement.

W0 comparison:

- The W1 manifest was compared against the W0 packaged manifest for information only.
- Differences were expected: source-built executables and DLLs have different hashes/sizes from the packaged specimen.
- W0-only extras not present in W1 include `RenderSystem_Direct3D11.dll`, `SR-Editor3 cfg.bat`, `StuntRally3 cfg.bat`, and `SR-Translator.exe`.

Next recommended W1 step:

- Begin launch smoke only: run `StuntRally3.exe` and `SR-Editor3.exe` from the staged W1 runtime root, capture logs/config deltas, record renderer/API behavior, and make only focused runtime-bundle corrections if a missing DLL/plugin/config blocker appears.

### W1 Launch Smoke Evidence

Full captured evidence:

```text
docs/windows/evidence/W1/smoke-command.txt
docs/windows/evidence/W1/smoke-output.txt
docs/windows/evidence/W1/smoke-result.txt
docs/windows/evidence/W1/smoke-deviations.txt
docs/windows/evidence/W1/smoke-log-times-before.txt
docs/windows/evidence/W1/smoke-log-times-after.txt
docs/windows/evidence/W1/smoke-process-check.txt
docs/windows/evidence/W1/runtime-bundle-report-after-smoke.txt
docs/windows/evidence/W1/runtime-manifest-after-smoke.csv
docs/windows/evidence/W1/logs-after-smoke/
docs/windows/evidence/W1/config-after-smoke/
```

Result:

- Pre-smoke runtime bundle validation passed.
- `StuntRally3.exe` launched from `bin\Release`.
- `SR-Editor3.exe` launched from `bin\Release`.
- Both hidden-window smoke launches timed out after 45 seconds and were stopped by the helper.
- Fresh Ogre logs were captured for both game and editor.
- MyGUI logs and config files were copied after smoke for context; their timestamps did not update during this hidden-window smoke run.
- No immediate missing-DLL, missing-plugin, or missing-config blocker was observed.
- No focused runtime-bundle correction was needed.
- Runtime manifest after smoke was generated.

Game launch evidence:

- Fresh `Ogre.log` at 21:03:58-21:03:59.
- Loaded `RenderSystem_GL3Plus`.
- Loaded `RenderSystem_Vulkan`.
- Loaded `Plugin_ParticleFX`.
- Enumerated Vulkan devices: `NVIDIA GeForce RTX 4070 SUPER` and `AMD Radeon(TM) Graphics`.
- Current `ogre.cfg` selects `Vulkan Rendering Subsystem`.

Editor launch evidence:

- Fresh `Ogre_ed.log` at 21:04:43.
- Loaded `RenderSystem_GL3Plus`.
- Loaded `RenderSystem_Vulkan`.
- Loaded `Plugin_ParticleFX`.
- Enumerated Vulkan devices: `NVIDIA GeForce RTX 4070 SUPER` and `AMD Radeon(TM) Graphics`.
- Current `ogre_ed.cfg` selects `OpenGL 3+ Rendering Subsystem`.

Interpretation:

- W1 source-built launch evidence is present for both game and editor.
- The smoke helper timeout is a recorded caveat, not a clean-exit pass.
- A game-specific OpenGL rendered-window smoke remains useful follow-up evidence because the current game config selected Vulkan, while editor config selected OpenGL 3+.

Next recommended W1 step:

- Run a W1 closure/promotion pass: mark W1 closed with the timeout caveat, promote the successful known-good ritual into `KNOWN_GOOD_2026.md`, and optionally add a narrow follow-up item for visible/OpenGL screenshot evidence without reopening build reproduction.

### W1 Closure Summary

Full captured evidence:

```text
docs/windows/evidence/W1/w1-closure-summary.txt
```

Final verdict:

- W1 is closed.
- The successful reproduced Windows 2026 ritual is promoted into `docs/windows/KNOWN_GOOD_2026.md`.
- The closure caveat remains explicit: launch smoke proves initialization from the source-built runtime, not clean process exit.
- No gameplay testing is claimed.
- Direct3D11 remains out of W0-W3 acceptance scope.

Recommended next milestones:

- W2: freeze/refine the blessed dependency layout and turn the ritual into a maintainer-friendly reconstruction guide.
- W3: improve guardrail scripts, especially runtime staging from multiple dependency roots and smoke behavior that can distinguish initialized-window evidence from timeout.
- Follow-up evidence: capture visible screenshots, preferably including a forced OpenGL game run, without reopening W1 build reproduction.

### W1 Follow-up: Visible OpenGL Evidence

Full captured evidence:

```text
docs/windows/evidence/W1-followups/visible-opengl-bundle-report.txt
docs/windows/evidence/W1-followups/visible-opengl-command.txt
docs/windows/evidence/W1-followups/visible-opengl-launch-output.txt
docs/windows/evidence/W1-followups/visible-opengl-menu-launch-output.txt
docs/windows/evidence/W1-followups/visible-opengl-fast-screenshot-output.txt
docs/windows/evidence/W1-followups/visible-opengl-result.txt
docs/windows/evidence/W1-followups/visible-opengl-deviations.txt
docs/windows/evidence/W1-followups/visible-opengl-log/
docs/windows/evidence/W1-followups/visible-opengl-config/
docs/windows/evidence/W1-followups/visible-opengl-screenshot.png
docs/windows/evidence/W1-followups/visible-opengl-fast-screenshot.png
docs/windows/evidence/W1-followups/visible-opengl-game-screenshot.png
```

Result:

- Runtime bundle validation passed before the visible OpenGL run.
- The live game `ogre.cfg` was backed up, set to `OpenGL 3+ Rendering Subsystem`, then restored after evidence capture.
- A visible Ogre setup screenshot was captured with OpenGL 3+ selected.
- A fullscreen black OpenGL render-window screenshot was captured shortly after accepting the setup dialog.
- Fresh `Ogre.log` confirms GL3Plus loaded, a GL 4.5 context was created, and the renderer was `NVIDIA GeForce RTX 4070 SUPER/PCIe/SSE2`.
- The run exited before a menu screenshot could be captured because `data\tracks` is missing in the source worktree.
- No tracks were cloned, copied, or junctioned in this pass.
- W1 remains closed; this follow-up records an honest runtime-content/layout blocker for fuller visible menu evidence.

### W1 Follow-up: Missing Track Corpus

Full captured evidence:

```text
docs/windows/evidence/W1-followups/no-tracks/no-tracks-command.txt
docs/windows/evidence/W1-followups/no-tracks/source-data-layout.txt
docs/windows/evidence/W1-followups/no-tracks/packaged-data-layout.txt
docs/windows/evidence/W1-followups/no-tracks/tracks-location-search.txt
docs/windows/evidence/W1-followups/no-tracks/gitignore-lfs-submodule-check.txt
docs/windows/evidence/W1-followups/no-tracks/tracks-config-check.txt
docs/windows/evidence/W1-followups/no-tracks/track-index-check.txt
docs/windows/evidence/W1-followups/no-tracks/source-track-errors.txt
docs/windows/evidence/W1-followups/no-tracks/package-track-sample.txt
docs/windows/evidence/W1-followups/no-tracks/no-tracks-root-cause.txt
docs/windows/evidence/W1-followups/no-tracks/no-tracks-recommended-fix.txt
docs/windows/evidence/W1-followups/no-tracks/no-tracks-result.txt
docs/windows/evidence/W1-followups/no-tracks/no-tracks-deviations.txt
```

Result:

- The source fork has `data` assets but no `data\tracks` directory.
- The preserved packaged specimen has `data\tracks` with 268 top-level entries, including `_previews`, and 267 `scene.xml` files.
- `config\tracks.ini` exists in the source fork, and `config\resources3.cfg` references `tracks/_previews`.
- Existing `sr3_track_index.csv/json` artifacts identify the packaged specimen's track root as the currently indexed known-good corpus.
- `docs/BuildingVS.md` explains the missing layout: SR3 tracks are a separate repository expected to be cloned with `git clone https://github.com/stuntrally/tracks3.git tracks` inside `data`.
- No active `.gitignore`, `.gitattributes`, `.gitmodules`, submodule, or Git LFS evidence explains the absence. This is an un-restored separate content checkout, not a source-build failure.
- W1 remains closed. This follow-up identifies the next runtime-content preservation task.

Recommended next action:

- Run a narrow content-corpus restoration pass. Prefer cloning `https://github.com/stuntrally/tracks3.git` into `$SR3_ROOT\data\tracks`, record branch/commit/counts, compare with the packaged 3.3 specimen, then rerun visible OpenGL menu evidence.
- If the live `tracks3` repository does not match the packaged 3.3 corpus, document the mismatch and consider a separate packaged-corpus preservation import from `C:\Games\stuntrally3-3.3\windows binaries\Stunt Rally 3.3\data\tracks`.

### W1 Follow-up: tracks3 Visible OpenGL Evidence

Full captured evidence:

```text
docs/windows/evidence/W1-followups/tracks3-visible-opengl/tracks3-command.txt
docs/windows/evidence/W1-followups/tracks3-visible-opengl/tracks3-layout.txt
docs/windows/evidence/W1-followups/tracks3-visible-opengl/runtime-bundle-report.txt
docs/windows/evidence/W1-followups/tracks3-visible-opengl/visible-opengl-launch-output.txt
docs/windows/evidence/W1-followups/tracks3-visible-opengl/visible-opengl-launch-output-second-run.txt
docs/windows/evidence/W1-followups/tracks3-visible-opengl/tracks3-result.txt
docs/windows/evidence/W1-followups/tracks3-visible-opengl/deviations.txt
docs/windows/evidence/W1-followups/tracks3-visible-opengl/logs/
docs/windows/evidence/W1-followups/tracks3-visible-opengl/config/
docs/windows/evidence/W1-followups/tracks3-visible-opengl/screenshot-after-tracks3-opengl.png
```

Result:

- `tracks3` was cloned into `C:\Games\stuntrally3-3.3\fork\stuntrally3-2026\data\tracks`.
- Source remote: `https://github.com/stuntrally/tracks3.git`.
- Branch: `main`.
- Commit: `84d77b69b512e4bde2fc1faaa5d51ab010bbaf76`.
- The checkout contains 270 top-level directories, including `.github`, `.vscode`, `_previews`, and track folders.
- The checkout contains 267 `scene.xml` files.
- Runtime bundle validation still passed.
- Visible OpenGL launch reached the Stunt Rally 3 window and tutorial/track selection UI.
- Fresh `Ogre.log` confirms `OpenGL 3+ Rendering Subsystem created`, `Created GL 4.5 context`, and `GL_RENDERER = NVIDIA GeForce RTX 4070 SUPER/PCIe/SSE2`.
- Fresh `Ogre.log` reports `Loaded Collections: 48` and `Total tracks: 238, total time: 11:29 h:m`.
- Fresh `MyGUI.log` reports `Gui successfully initialized`.
- The accepted screenshot is `screenshot-after-tracks3-opengl.png`.
- The process was stopped after screenshot capture; this remains visible launch/menu evidence, not clean-exit smoke or gameplay testing.
- W1 remains closed.

## W3 Script Inventory

Scripts live in `tools/windows/`.

- `Test-WindowsBuildLayout.ps1`: verifies expected source, dependency, and build layout.
- `Test-WindowsRuntimeBundle.ps1`: verifies required runtime files and plugin config entries.
- `Copy-WindowsRuntimeDlls.ps1`: stages the known-good DLL set into a runtime directory.
- `Start-WindowsSmoke.ps1`: launches game/editor smoke checks and reports log paths.
- `Get-WindowsRuntimeManifest.ps1`: writes SHA256/size manifests for runtime files.
- `Compare-WindowsRuntimeManifest.ps1`: compares current runtime files against a saved manifest.

Read-only default: scripts must not mutate files unless their purpose is clearly copy/stage.
