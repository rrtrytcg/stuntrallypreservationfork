call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\Common7\Tools\VsDevCmd.bat" -arch=x64 -host_arch=x64
cd /d C:\dev\Ogre
if not exist ogre-next git clone --branch v3-0 https://github.com/OGRECave/ogre-next
cd /d C:\dev\Ogre\ogre-next
git status --short
git branch --show-current
git rev-parse HEAD
git log -1 --oneline
if not exist Dependencies mklink /D Dependencies ..\ogre-next-deps\build\ogredeps
