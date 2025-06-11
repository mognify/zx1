# Levi Mogford 6/11/2025 - has been proofread and tested. Used Github Copilot to generate
# Self-elevate the script if not already running as admin
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Elevating to Administrator..."
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Import-Module ActiveDirectory

function Enable-CtrlA {
    param([System.Windows.Forms.TextBox]$textbox)
    $textbox.Add_KeyDown({
        if ($_.Control -and $_.KeyCode -eq [System.Windows.Forms.Keys]::A) {
            $_.SuppressKeyPress = $true
            $_.SourceControl.SelectAll()
        }
    })
}

function Test-IsAdmin {
    $currentIdentity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object System.Security.Principal.WindowsPrincipal($currentIdentity)
    return $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}
if (-not (Test-IsAdmin)) {
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = 'powershell.exe'
    $psi.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    $psi.Verb = 'runas'
    [System.Diagnostics.Process]::Start($psi) | Out-Null
    exit
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

#--- Form setup ---
$form = New-Object System.Windows.Forms.Form
$form.Text = "AD Group Manager"
$form.Size = New-Object System.Drawing.Size(700,540)
$form.BackColor = 'Black'
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false

$font = New-Object System.Drawing.Font("Consolas", 12, [System.Drawing.FontStyle]::Regular)
$fontLabel = New-Object System.Drawing.Font("Consolas", 13, [System.Drawing.FontStyle]::Regular)

#--- Top search for target user ---
$lblUser = New-Object System.Windows.Forms.Label
$lblUser.Text = "Target User:"
$lblUser.Font = $fontLabel
$lblUser.ForeColor = 'White'
$lblUser.Location = New-Object System.Drawing.Point(200, 20)
$lblUser.AutoSize = $true
$form.Controls.Add($lblUser)

$txtUser = New-Object System.Windows.Forms.TextBox
$txtUser.Location = New-Object System.Drawing.Point(330, 18)
$txtUser.Size = New-Object System.Drawing.Size(140, 32)
$txtUser.Font = $fontLabel
$txtUser.ForeColor = 'Lime'
$txtUser.BackColor = 'Black'
$form.Controls.Add($txtUser)
Enable-CtrlA $txtUser

$btnSearch = New-Object System.Windows.Forms.Button
$btnSearch.Text = "Search"
$btnSearch.Font = $font
$btnSearch.Location = New-Object System.Drawing.Point(480, 16)
$btnSearch.Size = New-Object System.Drawing.Size(90, 32)
$btnSearch.ForeColor = 'White'
$form.Controls.Add($btnSearch)

#--- All Available AD Groups label and search ---
$lblAllGroups = New-Object System.Windows.Forms.Label
$lblAllGroups.Text = "All Available AD Groups"
$lblAllGroups.Font = $font
$lblAllGroups.ForeColor = 'White'
$lblAllGroups.Location = New-Object System.Drawing.Point(20, 60)
$lblAllGroups.AutoSize = $true
$form.Controls.Add($lblAllGroups)

# Live filter label
$lblFilter = New-Object System.Windows.Forms.Label
$lblFilter.Text = "Filter:"
$lblFilter.Font = $font
$lblFilter.ForeColor = 'White'
$lblFilter.Location = New-Object System.Drawing.Point(20, 85)
$lblFilter.AutoSize = $true
$form.Controls.Add($lblFilter)

# Live filter textbox
$txtFilter = New-Object System.Windows.Forms.TextBox
$txtFilter.Location = New-Object System.Drawing.Point(80, 82)
$txtFilter.Size = New-Object System.Drawing.Size(190, 28)
$txtFilter.Font = $font
$txtFilter.BackColor = 'Black'
$txtFilter.ForeColor = 'Lime'
$form.Controls.Add($txtFilter)
Enable-CtrlA $txtFilter

#--- User's Current AD Groups label ---
$lblUserGroups = New-Object System.Windows.Forms.Label
$lblUserGroups.Text = "User's Current AD Groups"
$lblUserGroups.Font = $font
$lblUserGroups.ForeColor = 'White'
$lblUserGroups.Location = New-Object System.Drawing.Point(360, 60)
$lblUserGroups.AutoSize = $true
$form.Controls.Add($lblUserGroups)

#--- All AD Groups checked listbox (now moved lower to make room for search) ---
$clbAllGroups = New-Object System.Windows.Forms.CheckedListBox
$clbAllGroups.Location = New-Object System.Drawing.Point(20, 115)
$clbAllGroups.Size = New-Object System.Drawing.Size(250, 275)
$clbAllGroups.Font = $font
$clbAllGroups.BackColor = 'Black'
$clbAllGroups.ForeColor = 'White'
$form.Controls.Add($clbAllGroups)

#--- User's Current AD Groups ListBox ---
$lbUserGroups = New-Object System.Windows.Forms.ListBox
$lbUserGroups.Location = New-Object System.Drawing.Point(360, 90)
$lbUserGroups.Size = New-Object System.Drawing.Size(250, 300)
$lbUserGroups.Font = $font
$lbUserGroups.BackColor = 'Black'
$lbUserGroups.ForeColor = 'Lime'
$form.Controls.Add($lbUserGroups)

#--- Buttons, all white text ---
$btnLoadPreset = New-Object System.Windows.Forms.Button
$btnLoadPreset.Text = "Load Preset"
$btnLoadPreset.Font = $font
$btnLoadPreset.Location = New-Object System.Drawing.Point(20, 400)
$btnLoadPreset.Size = New-Object System.Drawing.Size(120, 32)
$btnLoadPreset.ForeColor = 'White'
$form.Controls.Add($btnLoadPreset)

$btnSavePreset = New-Object System.Windows.Forms.Button
$btnSavePreset.Text = "Save Preset"
$btnSavePreset.Font = $font
$btnSavePreset.Location = New-Object System.Drawing.Point(150, 400)
$btnSavePreset.Size = New-Object System.Drawing.Size(120, 32)
$btnSavePreset.ForeColor = 'White'
$form.Controls.Add($btnSavePreset)

$btnReset = New-Object System.Windows.Forms.Button
$btnReset.Text = "Reset"
$btnReset.Font = $font
$btnReset.Location = New-Object System.Drawing.Point(360, 400)
$btnReset.Size = New-Object System.Drawing.Size(140, 32)
$btnReset.ForeColor = 'White'
$form.Controls.Add($btnReset)

$btnApply = New-Object System.Windows.Forms.Button
$btnApply.Text = "Apply updates"
$btnApply.Font = $font
$btnApply.Location = New-Object System.Drawing.Point(510, 400)
$btnApply.Size = New-Object System.Drawing.Size(140, 32)
$btnApply.ForeColor = 'White'
$form.Controls.Add($btnApply)

#--- Helper: group data and filtering ---
$global:AllGroupsListFull = Get-ADGroup -Filter * | Select-Object -ExpandProperty Name | Sort-Object
$global:AllGroupsList = $global:AllGroupsListFull
$global:CheckedGroups = @{}

function Show-Message($msg, $title="Info") {
    [System.Windows.Forms.MessageBox]::Show($msg, $title, [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
}

function Get-UserADGroups($username) {
    try {
        $groups = Get-ADUser -Identity $username -Properties MemberOf | Select-Object -ExpandProperty MemberOf
        if ($groups) {
            $groups | ForEach-Object {
                $_ -replace '^CN=([^,]+).+$','$1'
            } | Sort-Object
        } else {
            @()
        }
    } catch {
        @()
    }
}
function Set-UserADGroups($username, $desiredGroups) {
    $userDN = (Get-ADUser -Identity $username).DistinguishedName
    $currentGroups = (Get-UserADGroups $username)
    # Add new groups
    $toAdd = $desiredGroups | Where-Object { $currentGroups -notcontains $_ }
    foreach ($grp in $toAdd) {
        try { Add-ADGroupMember -Identity $grp -Members $username -ErrorAction Stop } catch { }
    }
    # Remove unchecked groups
    $toRemove = $currentGroups | Where-Object { $desiredGroups -notcontains $_ }
    foreach ($grp in $toRemove) {
        try { Remove-ADGroupMember -Identity $grp -Members $username -Confirm:$false -ErrorAction Stop } catch { }
    }
}

#--- Filtering logic ---
function Refresh-AllGroupsListBox {
    $filter = $txtFilter.Text.Trim().ToLower()
    $clbAllGroups.Items.Clear()
    $visibleGroups = if ($filter) {
        $global:AllGroupsListFull | Where-Object { $_.ToLower().Contains($filter) }
    } else {
        $global:AllGroupsListFull
    }
    $global:AllGroupsList = $visibleGroups

    foreach ($group in $visibleGroups) {
        $idx = $clbAllGroups.Items.Add($group)
        if ($global:CheckedGroups.ContainsKey($group) -and $global:CheckedGroups[$group]) {
            $clbAllGroups.SetItemChecked($idx, $true)
        }
    }
    Update-UserGroupListBox
}

function Update-UserGroupListBox {
    $lbUserGroups.Items.Clear()
    foreach ($i in 0..($clbAllGroups.Items.Count-1)) {
        if ($clbAllGroups.GetItemChecked($i)) {
            $lbUserGroups.Items.Add($clbAllGroups.Items[$i])
        }
    }
}

#--- When a checkmark is toggled, update right pane and store state ---
$clbAllGroups.add_ItemCheck({
    $idx = $_.Index
    $group = $clbAllGroups.Items[$idx]
    $checked = ($_.NewValue -eq [System.Windows.Forms.CheckState]::Checked)
    $global:CheckedGroups[$group] = $checked
    Start-Sleep -Milliseconds 50
    $form.BeginInvoke([Action]{ Update-UserGroupListBox })
})

# Live filter event: update list as user types
$txtFilter.Add_TextChanged({ Refresh-AllGroupsListBox })

#--- User search/load logic ---
function Load-UserGroups {
    param($username)
    $userGroups = Get-UserADGroups $username
    if (-not $userGroups) {
        Show-Message "User not found or has no groups." "Error"
        return
    }
    # Store check state for all groups
    foreach ($grp in $global:AllGroupsListFull) {
        $global:CheckedGroups[$grp] = $userGroups -contains $grp
    }
    # Refresh list based on filter and checkmarks
    Refresh-AllGroupsListBox
}

$btnSearch.Add_Click({
    $uname = $txtUser.Text.Trim()
    if ($uname) { Load-UserGroups $uname }
})
$btnReset.Add_Click({
    $uname = $txtUser.Text.Trim()
    if ($uname) { Load-UserGroups $uname }
})

#--- Apply updates ---
$btnApply.Add_Click({
    $uname = $txtUser.Text.Trim()
    if (-not $uname) { Show-Message "Enter a username first." "Error"; return }
    $desiredGroups = $global:CheckedGroups.GetEnumerator() | Where-Object { $_.Value } | ForEach-Object { $_.Key }
    try {
        Set-UserADGroups $uname $desiredGroups
        Show-Message "Group memberships updated."
        Load-UserGroups $uname
    } catch {
        Show-Message "Failed to update groups.`n$($_.Exception.Message)" "Error"
    }
})

#--- Load/Save Preset ---
$btnLoadPreset.Add_Click({
    $ofd = New-Object System.Windows.Forms.OpenFileDialog
    $ofd.Filter = "Text Files (*.txt)|*.txt"
    $ofd.InitialDirectory = [Environment]::GetFolderPath("Desktop")
    if ($ofd.ShowDialog() -eq 'OK') {
        $presetGroups = Get-Content $ofd.FileName
        foreach ($grp in $global:AllGroupsListFull) {
            $global:CheckedGroups[$grp] = $presetGroups -contains $grp
        }
        Refresh-AllGroupsListBox
    }
})

$btnSavePreset.Add_Click({
    $sfd = New-Object System.Windows.Forms.SaveFileDialog
    $sfd.Filter = "Text Files (*.txt)|*.txt"
    $sfd.InitialDirectory = [Environment]::GetFolderPath("Desktop")
    if ($sfd.ShowDialog() -eq 'OK') {
        $checkedGroups = $global:CheckedGroups.GetEnumerator() | Where-Object { $_.Value } | ForEach-Object { $_.Key }
        $checkedGroups | Set-Content $sfd.FileName
    }
})

<#$lbUserGroups.Add_MouseDoubleClick({
    # Get mouse location
    $mousePos = $lbUserGroups.PointToClient([System.Windows.Forms.Cursor]::Position)
    $clickedIdx = $lbUserGroups.IndexFromPoint($mousePos)
    if ($clickedIdx -ge 0) {
        $targetGroupName = $lbUserGroups.Items[$clickedIdx].ToString().Trim()
        $txtFilter.Text = "" # Clear filter (triggers Refresh-AllGroupsListBox)
        $form.BeginInvoke([Action]{
            Start-Sleep -Milliseconds 100
            # Find and scroll to the item in the left pane
            $idx = -1
            for ($i = 0; $i -lt $clbAllGroups.Items.Count; $i++) {
                $leftGroupName = $clbAllGroups.Items[$i].ToString().Trim()
                if ($leftGroupName -eq $targetGroupName) {
                    $idx = $i
                    break
                }
            }
            if ($idx -ge 0) {
                $clbAllGroups.TopIndex = $idx
                $clbAllGroups.SelectedIndex = $idx
                $clbAllGroups.Focus()
            }
        })
    }
})#>

#--- Initial load ---
foreach ($grp in $global:AllGroupsListFull) { $global:CheckedGroups[$grp] = $false }
Refresh-AllGroupsListBox

$form.Add_Shown({ $form.Activate() })
[void]$form.ShowDialog()
