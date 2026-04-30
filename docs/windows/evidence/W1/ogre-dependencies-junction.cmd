cd /d C:\dev\Ogre\ogre-next
if not exist Dependencies mklink /J Dependencies ..\ogre-next-deps\build\ogredeps
dir Dependencies
