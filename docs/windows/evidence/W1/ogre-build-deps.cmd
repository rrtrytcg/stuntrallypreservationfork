call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\Common7\Tools\VsDevCmd.bat" -arch=x64 -host_arch=x64
set CMAKE_BIN=C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe
cd /d C:\dev\Ogre\ogre-next-deps\build
"%CMAKE_BIN%" --build . --config Debug
"%CMAKE_BIN%" --build . --target install --config Debug
"%CMAKE_BIN%" --build . --config Release
"%CMAKE_BIN%" --build . --target install --config Release
