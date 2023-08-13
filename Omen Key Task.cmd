@echo off
schtasks /create /tn "Omen Key" /xml "%~dpn0.xml"
