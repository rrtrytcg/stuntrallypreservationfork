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
| W1 - Reproduce existing Windows build manually once | Started | Release x64 game and editor are built from source and launched from the built tree. |
| W2 - Freeze blessed dependency layout | Not started | `KNOWN_GOOD_2026.md` can guide a maintainer through the successful layout without undocumented steps. |
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
- [ ] Download/clone/build dependencies following `docs/BuildingVS.md` before attempting any package-manager replacement. Ogre-next-deps are built; non-Ogre SR3 dependencies remain pending.
- [x] Build Ogre-Next branch `v3-0` with Atmosphere and Planar Reflections enabled.
- [ ] Build MyGUI-next branch `ogre3` against the reproduced Ogre-Next output.
- [ ] Configure SR3 Release x64 using the historical Windows release CMake route, documenting every path edit or file rename.
- [ ] Build `StuntRally3.exe` and `SR-Editor3.exe`.
- [ ] Stage runtime DLLs and `plugins.cfg` using the W3 scripts where possible.
- [ ] Validate the built runtime bundle, generate a W1 manifest, and run launch smoke.
- [ ] Promote the final successful machine/toolchain/dependency layout into `KNOWN_GOOD_2026.md`.

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

## W3 Script Inventory

Scripts live in `tools/windows/`.

- `Test-WindowsBuildLayout.ps1`: verifies expected source, dependency, and build layout.
- `Test-WindowsRuntimeBundle.ps1`: verifies required runtime files and plugin config entries.
- `Copy-WindowsRuntimeDlls.ps1`: stages the known-good DLL set into a runtime directory.
- `Start-WindowsSmoke.ps1`: launches game/editor smoke checks and reports log paths.
- `Get-WindowsRuntimeManifest.ps1`: writes SHA256/size manifests for runtime files.
- `Compare-WindowsRuntimeManifest.ps1`: compares current runtime files against a saved manifest.

Read-only default: scripts must not mutate files unless their purpose is clearly copy/stage.
