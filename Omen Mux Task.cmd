@echo off
schtasks /create /tn "Omen Mux" /xml "%~dpn0.xml"
