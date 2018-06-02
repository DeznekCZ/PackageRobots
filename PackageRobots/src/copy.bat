@echo off
if exist "C:\Users\%USERNAME%\AppData\Roaming\Factorio\mods\%3_%2" (
	echo removeLast
	rmdir "C:\Users\%USERNAME%\AppData\Roaming\Factorio\mods\%3_%2" /S /Q
)
xcopy %1\* "C:\Users\%USERNAME%\AppData\Roaming\Factorio\mods\%3_%2" /e /I