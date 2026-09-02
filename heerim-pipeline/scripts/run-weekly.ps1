# Heerim content weekly pipeline - runner (ASCII only; Korean instructions live in weekly-prompt.txt)
# Task Scheduler runs this every Monday. Does pipeline steps 1-3 (scan -> notion log -> topic pick).
# Step 4 (drafting) is done by a person after picking topics.

$ErrorActionPreference = "Stop"

$ContentDir = Split-Path -Parent $PSScriptRoot          # ...\Desktop\content
$Claude     = "C:\Users\hahahoho\.local\bin\claude.exe"
$PromptFile = Join-Path $PSScriptRoot "weekly-prompt.txt"
$LogDir     = Join-Path $ContentDir "outputs\_logs"
$Stamp      = Get-Date -Format "yyyy-MM-dd_HHmm"
$LogFile    = Join-Path $LogDir ("weekly-" + $Stamp + ".log")

New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
Set-Location $ContentDir

("[" + (Get-Date -Format s) + "] weekly pipeline start") | Out-File -FilePath $LogFile -Encoding utf8

# ASCII-only instruction; claude reads the real (Korean) prompt file itself with correct UTF-8.
$Instruction = "Read the file scripts/weekly-prompt.txt and carry out every instruction in it exactly. Work only inside this folder."

& $Claude -p $Instruction --dangerously-skip-permissions --output-format text 2>&1 |
    Out-File -FilePath $LogFile -Encoding utf8 -Append

$code = $LASTEXITCODE
("[" + (Get-Date -Format s) + "] exit code " + $code) | Out-File -FilePath $LogFile -Encoding utf8 -Append
exit $code
