@echo off
wget -i "%~dpn0.txt"
for %%f in (*.json) do dd bs=38 skip=1 if="%%~f" of="%%~nf.json.gz"
for %%f in (*.json.gz) do gzip -df "%%f"
del /f /q *.json.gz
