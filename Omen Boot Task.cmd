@echo off
setlocal

set task_filename=OmenHwCtl.*
set task_xml_data=%~dpn0.xml

copy /y "%~dp0%task_filename%" "%SystemRoot%\System32"

rem Note: Using an XML template is the only way
rem to ensure the task runs even if on battery power

schtasks /create /tn "Omen Boot" /xml "%task_xml_data%"

rem Otherwise, the task of creating a task would have been much more straightforward:
rem schtasks /create /sc ONSTART /tn "Maximum GPU Power" /tr "%task_filename%" /ru System /f
