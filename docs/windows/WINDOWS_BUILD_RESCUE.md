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
| W0 - Known-good Windows binary baseline | Partial, not closed | Hashes, logs, config snapshots, screenshots, DLL/plugin manifest, and smoke notes are present in repo form. |
| W1 - Reproduce existing Windows build manually once | Not started | Release x64 game and editor are built from source and launched from the built tree. |
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

## W3 Script Inventory

Scripts live in `tools/windows/`.

- `Test-WindowsBuildLayout.ps1`: verifies expected source, dependency, and build layout.
- `Test-WindowsRuntimeBundle.ps1`: verifies required runtime files and plugin config entries.
- `Copy-WindowsRuntimeDlls.ps1`: stages the known-good DLL set into a runtime directory.
- `Start-WindowsSmoke.ps1`: launches game/editor smoke checks and reports log paths.
- `Get-WindowsRuntimeManifest.ps1`: writes SHA256/size manifests for runtime files.
- `Compare-WindowsRuntimeManifest.ps1`: compares current runtime files against a saved manifest.

Read-only default: scripts must not mutate files unless their purpose is clearly copy/stage.
