function New-Shortcut {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True)][ValidateNotNullOrEmpty()][string]$ShortcutPath,
        [Parameter(Mandatory = $True)][ValidateNotNullOrEmpty()][string]$Target,
        [ValidateNotNullOrEmpty()][string]$Arguments,
        [ValidateNotNullOrEmpty()][string]$Icon,
        [switch]$IfExist
    )

    if ($IfExist) {
        if (!(Test-Path -Path $ShortcutPath -PathType Leaf)) {
            return
        }
    }

    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($ShortcutPath)
    $Shortcut.TargetPath = $Target
    if ($Icon) { $Shortcut.IconLocation = $Icon }
    if ($Arguments) { $Shortcut.Arguments = $Arguments }
    $Shortcut.Save()
}

Write-Output "Creating Desktop & Start Menu shortcuts..."
$defaultShortcut = "$([Environment]::GetFolderPath('CommonDesktopDirectory'))\Atlas.lnk"
New-Shortcut -Icon "$([Environment]::GetFolderPath('Windows'))\AtlasModules\Other\atlas-folder.ico,0" -Target "$([Environment]::GetFolderPath('Windows'))\AtlasDesktop" -ShortcutPath $defaultShortcut
Copy-Item $defaultShortcut -Destination "$([Environment]::GetFolderPath('CommonStartMenu'))\Programs" -Force

Write-Output "Creating services shortcuts..."
$runAsTI = "$([Environment]::GetFolderPath('Windows'))\AtlasModules\Scripts\RunAsTI.cmd"
$default = "$([Environment]::GetFolderPath('Windows'))\AtlasDesktop\8. Troubleshooting\Default"
New-Shortcut -ShortcutPath "$default Windows Services and Drivers.lnk" -Target "$runAsTI" -Arguments "$([Environment]::GetFolderPath('Windows'))\AtlasModules\Other\winServices.reg" -Icon "$([Environment]::GetFolderPath('Windows'))\regedit.exe,1"
New-Shortcut -ShortcutPath "$default Atlas Services and Drivers.lnk" -Target "$runAsTI" -Arguments "$([Environment]::GetFolderPath('Windows'))\AtlasModules\Other\atlasServices.reg" -Icon "$([Environment]::GetFolderPath('Windows'))\regedit.exe,1"

Write-Output "Making Windows Tools shortcuts dark mode for Windows 11..."
$newTargetPath = "$([Environment]::GetFolderPath('Windows'))\explorer.exe"
$newArgs = "shell:::{D20EA4E1-3957-11d2-A40B-0C5020524153}"
foreach ($user in (Get-ChildItem -Path "$env:SystemDrive\Users" -Directory | Where-Object { 'Public' -notcontains $_.Name }).FullName) {
    New-Shortcut -ShortcutPath "$user\Microsoft\Windows\Start Menu\Programs\Administrative Tools.lnk" -Target $newTargetPath -Arguments $newArgs -IfExist
}