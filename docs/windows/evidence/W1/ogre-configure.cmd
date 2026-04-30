call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\Common7\Tools\VsDevCmd.bat" -arch=x64 -host_arch=x64
set CMAKE_BIN=C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe
set GENERATOR=Visual Studio 17 2022
set PLATFORM=x64
cd /d C:\dev\Ogre\ogre-next
mkdir build 2>nul
cd build
"%CMAKE_BIN%" -D OGRE_CONFIG_THREAD_PROVIDER=0 -D OGRE_CONFIG_THREADS=0 -D OGRE_BUILD_COMPONENT_SCENE_FORMAT=1 -D OGRE_BUILD_COMPONENT_PLANAR_REFLECTIONS=1 -D OGRE_BUILD_COMPONENT_ATMOSPHERE=1 -D OGRE_BUILD_SAMPLES2=1 -D OGRE_BUILD_TESTS=1 -D OGRE_DEPENDENCIES_DIR=..\..\ogre-next-deps\build\ogredeps -G "%GENERATOR%" -A %PLATFORM% ..
