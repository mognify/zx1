## BEFORE ANYTHING, MAKE SURE:
1. "View file extensions" is on
2. "Allow local PowerShell Scripts to run without being signed" (Windows key -> start typing "Allow local powershell")
	![[Pasted image 20250605152206.png]]

# Software-related
- Standard software installs?
	- PVault, [[RFMS]], 
- Do we use any scripts for pushing any installs remotely? (if not, that's something I can look into making)
- do we do M365 administration? Mailing lists/groups and stuff
## Scripting-related
- What scripts are commonly used?
### Powershell-related
Allow local PowerShell scripts to run without being signed
#### Installing Active Directory and Group Policy tools (RSAT)
Install AD and GPO stuff from RSAT (takes a while)
```powershell
Add-WindowsCapability -Online -Name "Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0"; Add-WindowsCapability -Online -Name "Rsat.GroupPolicy.Management.Tools~~~~0.0.1.0"
```

to check if they're installed:
```powershell
"Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0","Rsat.GroupPolicy.Management.Tools~~~~0.0.1.0" | ForEach-Object {
    Get-WindowsCapability -Online -Name $_ | Select-Object DisplayName, State
}
```

in case one is installed but the other isnt, here are the individual install commands:
```powershell: optional individual RSAT install
# Active Directory Domain Services and Lightweight Directory Tools
Add-WindowsCapability -Online -Name "Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0"

# Group Policy Management Tools (optional, but common for AD admin)
Add-WindowsCapability -Online -Name "Rsat.GroupPolicy.Management.Tools~~~~0.0.1.0"
```
## AD-related
- What groups do new hires typically need to be added to?
# Hardware-related
### Printers
- What model printers are used? What software is used for them?
### Misc. devices
- Scan guns? "Kiosks"? 
### Laptops, desktops, mobile devices
- Setup instructions for each

