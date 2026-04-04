[CmdletBinding()]
param(
    [string]$ReadmePath,
    [string]$Token = $env:GITHUB_TOKEN,
    [switch]$Preview
)

$ErrorActionPreference = "Stop"

if (-not $ReadmePath) {
    $ReadmePath = Join-Path $PSScriptRoot "..\README.md"
}

$startMarker = "<!-- PROJECT-HIGHLIGHTS:START -->"
$endMarker = "<!-- PROJECT-HIGHLIGHTS:END -->"

$projectConfigs = @(
    @{
        Slug = "vadlike/VAD-Control-Suite"
        Title = "VAD Control Suite"
        Summary = "Tray-first Windows control center for monitor blackout, desktop layouts, window tools, quick launcher folders, jiggler modes, and scheduled power actions."
        AccentBadges = @(
            @{ Label = "Flagship"; Message = "Windows Suite"; Color = "991b1b"; Alt = "Flagship" }
        )
        ExtraBadges = @(
            @{ Label = "Platform"; Message = "Windows 10/11"; Color = "0078D4"; Alt = "Platform" },
            @{ Label = "Category"; Message = "Desktop Control"; Color = "1d4ed8"; Alt = "Category" }
        )
    },
    @{
        Slug = "vadlike/MicGuard"
        Title = "MicGuard"
        Summary = "Lightweight Windows audio utility that keeps your preferred microphone selected, blocks unwanted device takeovers, and gives fast per-app volume control from a tray-first workflow."
        AccentBadges = @(
            @{ Label = "Featured"; Message = "Audio Guard"; Color = "0f766e"; Alt = "Featured" }
        )
        ExtraBadges = @(
            @{ Label = "Platform"; Message = "Windows 10/11"; Color = "0078D4"; Alt = "Platform" },
            @{ Label = "Category"; Message = "Audio Utility"; Color = "0f766e"; Alt = "Category" }
        )
    },
    @{
        Slug = "vadlike/NanoKVM-Pro-Mount-web-manager"
        Title = "NanoKVM Pro Mount Web Manager"
        Summary = "NanoKVM Pro web manager with a hardened file manager, inline ISO mount actions, upload-from-URL support, and torrent downloads in a dark NanoKVM-themed UI."
        AccentBadges = @(
            @{ Label = "NanoKVM"; Message = "Security Hardened"; Color = "7c2d12"; Alt = "NanoKVM" }
        )
        ExtraBadges = @(
            @{ Label = "Device"; Message = "NanoKVM Pro"; Color = "b91c1c"; Alt = "Device" },
            @{ Label = "Category"; Message = "Web Manager"; Color = "0f766e"; Alt = "Category" }
        )
    },
    @{
        Slug = "vadlike/NanoKVM-Pro-DIY-APPS"
        Title = "NanoKVM Pro DIY Apps"
        Summary = "Curated collection of standalone touch-friendly apps for NanoKVM Pro, covering Wi-Fi, virtual media, KVM switching, HID automation, network testing, and service toggles."
        AccentBadges = @(
            @{ Label = "NanoKVM"; Message = "Touch Apps"; Color = "1d4ed8"; Alt = "NanoKVM" }
        )
        ExtraBadges = @(
            @{ Label = "Device"; Message = "NanoKVM Pro"; Color = "b91c1c"; Alt = "Device" },
            @{ Label = "Category"; Message = "App Hub"; Color = "1d4ed8"; Alt = "Category" }
        )
    },
    @{
        Slug = "vadlike/NanoKVM-Pro-mirror"
        Title = "NanoKVM Pro Mirror"
        Summary = "Portable Windows viewer for mirroring the local NanoKVM LCD over SSH, with mouse tap and swipe control plus extra buttons for knob-style actions."
        AccentBadges = @(
            @{ Label = "NanoKVM"; Message = "SSH Mirror"; Color = "334155"; Alt = "NanoKVM" }
        )
        ExtraBadges = @(
            @{ Label = "Platform"; Message = "Windows"; Color = "0078D4"; Alt = "Platform" },
            @{ Label = "Category"; Message = "Remote Control"; Color = "1d4ed8"; Alt = "Category" }
        )
    }
)

function New-BadgeTag {
    param(
        [Parameter(Mandatory = $true)][string]$Url,
        [Parameter(Mandatory = $true)][string]$Alt
    )

    return "  <img src=""$Url"" alt=""$Alt"">"
}

function New-CustomBadgeUrl {
    param(
        [Parameter(Mandatory = $true)][string]$Label,
        [Parameter(Mandatory = $true)][string]$Message,
        [Parameter(Mandatory = $true)][string]$Color
    )

    $encodedLabel = [uri]::EscapeDataString($Label)
    $encodedMessage = [uri]::EscapeDataString($Message)
    return "https://img.shields.io/badge/{0}-{1}-{2}?style=flat-square" -f $encodedLabel, $encodedMessage, $Color
}

function Get-GitHubRepository {
    param(
        [Parameter(Mandatory = $true)][string]$Slug,
        [Parameter(Mandatory = $true)][hashtable]$Headers
    )

    $uri = "https://api.github.com/repos/$Slug"
    return Invoke-RestMethod -Uri $uri -Headers $Headers
}

$headers = @{
    Accept = "application/vnd.github+json"
    "User-Agent" = "vadlike-readme-project-updater"
}

if ($Token) {
    $headers.Authorization = "Bearer $Token"
}

$cards = New-Object System.Collections.Generic.List[string]

foreach ($config in $projectConfigs) {
    $repo = Get-GitHubRepository -Slug $config.Slug -Headers $headers
    $accentBadges = New-Object System.Collections.Generic.List[string]
    $badges = New-Object System.Collections.Generic.List[string]

    foreach ($accentBadge in $config.AccentBadges) {
        $accentBadges.Add((New-BadgeTag -Url (New-CustomBadgeUrl -Label $accentBadge.Label -Message $accentBadge.Message -Color $accentBadge.Color) -Alt $accentBadge.Alt))
    }

    $badges.Add((New-BadgeTag -Url "https://img.shields.io/github/stars/$($config.Slug)?style=flat-square" -Alt "Stars"))
    $badges.Add((New-BadgeTag -Url "https://img.shields.io/github/last-commit/$($config.Slug)?style=flat-square" -Alt "Last commit"))

    if ($repo.language) {
        $badges.Add((New-BadgeTag -Url "https://img.shields.io/github/languages/top/$($config.Slug)?style=flat-square" -Alt "Top language"))
    }

    if ($repo.license -and $repo.license.spdx_id -and $repo.license.spdx_id -ne "NOASSERTION") {
        $badges.Add((New-BadgeTag -Url "https://img.shields.io/github/license/$($config.Slug)?style=flat-square" -Alt "License"))
    }

    foreach ($extraBadge in $config.ExtraBadges) {
        $badges.Add((New-BadgeTag -Url (New-CustomBadgeUrl -Label $extraBadge.Label -Message $extraBadge.Message -Color $extraBadge.Color) -Alt $extraBadge.Alt))
    }

    $card = @"
    <td width="50%" valign="top">
      <p>
$($accentBadges -join "`r`n")
      </p>
      <h3>$($config.Title)</h3>
      <p>$($config.Summary)</p>
      <p>
$($badges -join "`r`n")
      </p>
      <p><a href="$($repo.html_url)"><strong>Open repository</strong></a></p>
    </td>
"@

    $cards.Add($card.TrimEnd())
}

$rows = New-Object System.Collections.Generic.List[string]
for ($i = 0; $i -lt $cards.Count; $i += 2) {
    $left = $cards[$i]
    $right = if ($i + 1 -lt $cards.Count) { $cards[$i + 1] } else { '    <td width="50%" valign="top"></td>' }

    $row = @"
  <tr>
$left
$right
  </tr>
"@

    $rows.Add($row.TrimEnd())
}

$generatedBlock = @"
$startMarker
<!-- Generated by scripts/update-project-highlights.ps1 -->
<table>
$($rows -join "`r`n")
</table>
$endMarker
"@

$readme = [System.IO.File]::ReadAllText($ReadmePath)

if (-not $readme.Contains($startMarker) -or -not $readme.Contains($endMarker)) {
    throw "README markers not found. Expected $startMarker and $endMarker."
}

$pattern = [regex]::Escape($startMarker) + ".*?" + [regex]::Escape($endMarker)
$updatedReadme = [regex]::Replace($readme, $pattern, [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $generatedBlock }, [System.Text.RegularExpressions.RegexOptions]::Singleline)

if ($Preview) {
    $generatedBlock
    exit 0
}

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($ReadmePath, $updatedReadme, $utf8NoBom)

Write-Output "Updated project highlights in $ReadmePath"
