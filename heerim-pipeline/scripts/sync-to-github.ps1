# Sync this folder into the content-store repo (subfolder heerim-pipeline/) and push to GitHub.
# Run when you want the GitHub copy updated:
#   powershell -NoProfile -ExecutionPolicy Bypass -File "c:\Users\hahahoho\Desktop\content\scripts\sync-to-github.ps1"
#
# Excludes: .git, outputs\_logs, reference\notion-setup.local.md (kept local only).

$Src  = Split-Path -Parent $PSScriptRoot                 # ...\Desktop\content
$Repo = "C:\Users\hahahoho\Desktop\content-store"
$Dst  = Join-Path $Repo "heerim-pipeline"
$Url  = "https://github.com/byhg88-lab/content-store.git"

if (-not (Test-Path (Join-Path $Repo ".git"))) {
    git clone $Url $Repo
}
git -C $Repo pull --quiet origin main

New-Item -ItemType Directory -Force -Path $Dst | Out-Null
robocopy $Src $Dst /MIR `
    /XD (Join-Path $Src ".git") (Join-Path $Src "outputs\_logs") `
    /XF "notion-setup.local.md" `
    /NFL /NDL /NJH /NJS /NP | Out-Null

git -C $Repo add heerim-pipeline
$msg = "Sync heerim-pipeline (" + (Get-Date -Format "yyyy-MM-dd HH:mm") + ")"
git -C $Repo commit -q -m $msg 2>$null
git -C $Repo push origin main
Write-Host ("Done: " + $msg) -ForegroundColor Green
