call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\Common7\Tools\VsDevCmd.bat" -arch=x64 -host_arch=x64
cd /d C:\dev
if not exist mygui-next git clone https://github.com/cryham/mygui-next --branch ogre3 --single-branch
cd /d C:\dev\mygui-next
git status --short
git branch --show-current
git rev-parse HEAD
git log -1 --oneline
