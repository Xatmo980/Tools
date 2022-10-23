@echo off
echo Converting Images!
For /R %%G in (*.tga) do (
convert.exe "%%G" -auto-orient "%%~nG.jpg"
move "%%~nG.jpg" "items"
Echo Converting %%G -> jpg )
Pause