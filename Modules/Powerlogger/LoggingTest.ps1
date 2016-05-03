#Example of logging functionality that is provided

Import-Module PowerLogger -Force -Verbose
Start-Logging -LoggingLevel DEBUG -TerminalLevel DEBUG -OutputTerminal $true -OverWriteLog -ScriptVersion 1.4
Write-PLVerbose "Verbose Message"
Write-PLDebug "Debug Message"
Write-PLDebug "Debug Forced to Terminal" -forceTerminal
Write-PLInfo "INFO Sub1" -Sublevel "sub1 "
Write-PLDEBUG "DEBUG Sub1 Yellow" -Sublevel "sub1 " -ForegroundColor Yellow
Write-PLVerbose "Verbos,e Sub1" -Sublevel "su,b1 "
Write-PLInfo "INFO Force csv" -ForceCSV 
Write-PLVerbose "Verbose Force csv" -ForceCSV 
Write-PLDebug "DEBUG Force csv" -ForceCSV
Write-PLVerbose "Verbose Force csv" -ForceCSV -LogFile C:\AUDIT.csv 
