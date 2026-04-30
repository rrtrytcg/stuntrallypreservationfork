call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\Common7\Tools\VsDevCmd.bat" -arch=x64 -host_arch=x64
set CMAKE_BIN=C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe
set GENERATOR=Visual Studio 17 2022
set PLATFORM=x64
mkdir C:\dev\Ogre 2>nul
cd /d C:\dev\Ogre
if not exist ogre-next-deps git clone --recurse-submodules --shallow-submodules https://github.com/OGRECave/ogre-next-deps
cd /d C:\dev\Ogre\ogre-next-deps
mkdir build 2>nul
cd build
"%CMAKE_BIN%" -G "%GENERATOR%" -A %PLATFORM% ..
