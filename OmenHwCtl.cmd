@echo off
powershell -ExecutionPolicy Bypass -NoLogo -NoProfile -Command "& '%~dpn0.ps1'" %*
