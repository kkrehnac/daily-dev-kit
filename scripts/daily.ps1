$notesDir = "C:\Users\kakre\My Drive\Notes\daily"
$today = Get-Date -Format "yyyy-MM-dd"
$todayPath = Join-Path $notesDir "$today.md"

if (!(Test-Path $notesDir)) {
    New-Item -ItemType Directory -Path $notesDir
}

if (!(Test-Path $todayPath)) {
    $migratedTasksBlock = ""
    $previousPath = $null

    # Search backwards to find the most recent daily note with undone tasks
    for ($i = 1; $i -le 30; $i++) {
        $previousDate = (Get-Date).AddDays(-$i).ToString("yyyy-MM-dd")
        $previousPathCandidate = Join-Path $notesDir "$previousDate.md"

        if (Test-Path $previousPathCandidate) {
            $undoneTasks = Select-String -Path $previousPathCandidate -Pattern "^- \[ \] " | ForEach-Object {
                ($_.Line -replace "\s+#MIG\d*", "") + " #MIG"
            }
            if ($undoneTasks) {
                $migratedTasksBlock = $undoneTasks -join "n"
                $previousPath = $previousPathCandidate
            }
            break
        }
    }

    $output = "# $todayn"

    $output += "n## Tasks"
    if ($migratedTasksBlock -ne "") {
        $output += "n$migratedTasksBlock"
    }

    $output += "nn## Notes"

    # Write the new file
    $output | Out-File -Encoding utf8 $todayPath

    # Clean migrated tasks from previous note
    if ($previousPath -and (Test-Path $previousPath)) {
        (Get-Content $previousPath) | Where-Object {$_ -notmatch "^- \[ \] "} | Set-Content $previousPath
    }
}

cd $notesDir
hx $todayPath
