# Registers this repo's skill/ definitions as Claude Code slash commands by
# creating NTFS junctions under .claude/skills/<name> that point at skill/<name>.
#
# Why a script instead of committing .claude/skills directly: junctions/symlinks
# don't survive a git clone as links (git would either ignore them or duplicate
# their target's files into real copies), so every clone/worktree needs to run
# this once. skill/ stays the single source of truth for all skill content.
#
# Usage: powershell -File scripts/link-skills.ps1

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$skillRoot = Join-Path $repoRoot 'skill'
$targetRoot = Join-Path $repoRoot '.claude\skills'

New-Item -ItemType Directory -Force -Path $targetRoot | Out-Null

Get-ChildItem -Path $skillRoot -Directory | ForEach-Object {
    $name = $_.Name
    $source = $_.FullName
    $link = Join-Path $targetRoot $name

    if (Test-Path $link) {
        Write-Host "skip  $name (already linked)"
        return
    }

    New-Item -ItemType Junction -Path $link -Target $source | Out-Null
    Write-Host "link  $name -> skill/$name"
}
