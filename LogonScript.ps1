#############################################################
# Needs WinRM enabled for remote logoff
# Edit to fit your environment
#Enter the location of where you want the user file to be stored
$UserFileLocation = "\\nas\login$\$env:username.txt"

if (!($UserFileLocation | Test-Path))
{
	New-Item $UserFileLocation -type file -Force | Out-Null
	Add-Content $UserFileLocation $env:computername
}
#------------------------------------------------------------
$computer = Get-Content $UserFileLocation #Reads txt file
#------------------------------------------------------------
#Enter the location of the personalized logo, max height should be 65px and max width should be 380px
$LogoLocation = "\\nas\login$\logo.png"
#------------------------------------------------------------
#Enter the txt you want to appear in the Window title bar
$MainFormTitle = "Нарушение на политика за сигурност"
#------------------------------------------------------------
#Enter the txt you want to appear in the window header
$WindowTitleMsg = "ВНИМАНИЕ: Вече сте вписани на друг компютър!"
#------------------------------------------------------------
#Enter the txt you wan to appear in the window body line 320
$Body = "Политиката за информационна сигурност на Организация не позволява едновременното използване на портебителски акаунт на повече от един компютър или използването на такъв на друг служител. Потребителят $env:username вече се използва, ако желаете да се отпишете от компютър с име: $computer, натиснете бутона (Отдалечено отписване)."
#------------------------------------------------------------
#Enter the total time in seconds befor auto logoff, keep in mind the total time it takes for a new user to login and for windows to create the profile.
$TimeSec = 60
#
#############################################################
# TODO: 1. add logic to test if the network connection is connected, if yes continue as normal, if no prompt for a network connection continue to log off in aloted amount of time if no connection is provided.
$lastWrite = (get-item $UserFileLocation).LastWriteTime
$timespan = new-timespan -days 0 -hours 0 -minutes 3
if ((Test-Path $UserFileLocation)`
	-and`
	($env:computername -ne (Get-Content $UserFileLocation))`
	-and`
	(((get-date) - $lastWrite) -lt $timespan))
{
#----------------------------------------------
#region Import Assemblies
#----------------------------------------------
[void][Reflection.Assembly]::Load('System.Windows.Forms, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
[void][Reflection.Assembly]::Load('System.Data, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
[void][Reflection.Assembly]::Load('System.Drawing, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a')

function Main {

Param ([String]$Commandline)

if((Call-MainForm_psf) -eq 'OK')
{
}
$global:ExitCode = 0
}

#region Source: MainForm.psf
function Call-MainForm_psf
{

#----------------------------------------------
#region Import the Assemblies
#----------------------------------------------
[void][reflection.assembly]::Load('System.Windows.Forms, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
[void][reflection.assembly]::Load('System.Data, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
[void][reflection.assembly]::Load('System.Drawing, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a')

#----------------------------------------------
#region Generated Form Objects
#----------------------------------------------
Add-Type -AssemblyName System.Windows.Forms

$MainForm = New-Object 'System.Windows.Forms.Form'
$panel2 = New-Object 'System.Windows.Forms.Panel'
#$ButtonCancel = New-Object 'System.Windows.Forms.Button'
$ButtonLogoffRemote = New-Object 'System.Windows.Forms.Button'
$ButtonLogoffLocal = New-Object 'System.Windows.Forms.Button'
$panel1 = New-Object 'System.Windows.Forms.Panel'
$labelITSystemsMaintenance = New-Object 'System.Windows.Forms.Label'
$labelSecondsLeftToLogoff = New-Object 'System.Windows.Forms.Label'
$labelTime = New-Object 'System.Windows.Forms.Label'
$labelInOrderToApplySecuri = New-Object 'System.Windows.Forms.Label'
$timerUpdate = New-Object 'System.Windows.Forms.Timer'
$InitialFormWindowState = New-Object 'System.Windows.Forms.FormWindowState'
$Logo = New-Object 'system.windows.Forms.PictureBox'

#----------------------------------------------
# User Generated Script
#----------------------------------------------
$TotalTime = $TimeSec
$MainForm_Load={
$labelTime.Text = "{0:D2}" -f $TotalTime
$script:StartTime = (Get-Date).AddSeconds($TotalTime)
$timerUpdate.Start()
}

$timerUpdate_Tick={
[TimeSpan]$span = $script:StartTime - (Get-Date)
$labelTime.Text = "{0:N0}" -f $span.TotalSeconds
$timerUpdate.Start()
if ($span.TotalSeconds -le 0)
{
$timerUpdate.Stop()
Shutdown /l /f
}
}

$ButtonLogoffLocal_Click = {
Shutdown /l /f
}

#----------------------------------------------
# Log off remote computer
# TODO: 1. Need to add logic to check if the user has been logged off the remote computer before continuing to the loop
#----------------------------------------------
$ButtonLogOffRemote_Click={
$computer = Get-Content $UserFileLocation
$session = ((& quser /server:$computer | ? { $_ -match $env:username }) -split ' +')[2]
$CurrentDomain = "LDAP://" + ([ADSI]"").distinguishedName
logoff $session /server:$computer
#	Remove-Item $UserFileLocation
	$MainForm.Hide()
	$Pivot = 1
	New-Item $UserFileLocation -type file -Force | Out-Null
	Add-Content $UserFileLocation $env:computername
	DO
	{
		if (!($UserFileLocation | Test-Path))
		{
			New-Item $UserFileLocation -type file -Force | Out-Null
			Add-Content $UserFileLocation $env:computername
		}
		$(Get-Item $UserFileLocation).lastwritetime=$(DATE)
		Start-Sleep -s 25
	}
	while ($Pivot -ne 0)
}

<#
$ButtonCancel_Click={
$MainForm.Close()
}
#>

$labelITSystemsMaintenance_Click={
}

$panel2_Paint=[System.Windows.Forms.PaintEventHandler]{
}

$labelTime_Click={
}

#----------------------------------------------
#region Generated Events
#----------------------------------------------
$Form_StateCorrection_Load=
{
$MainForm.WindowState = $InitialFormWindowState
}

$Form_StoreValues_Closing=
{
}

$Form_Cleanup_FormClosed=
{
try
{

#$ButtonCancel.remove_Click($buttonCancel_Click)
$ButtonLogoffRemote.remove_Click($ButtonLogoffRemote_Click)
$ButtonLogoffLocal.remove_Click($ButtonLogoffLocal_Click)
$panel2.remove_Paint($panel2_Paint)
$labelITSystemsMaintenance.remove_Click($labelITSystemsMaintenance_Click)
$labelTime.remove_Click($labelTime_Click)
$MainForm.remove_Load($MainForm_Load)
$timerUpdate.remove_Tick($timerUpdate_Tick)
$MainForm.remove_Load($Form_StateCorrection_Load)
$MainForm.remove_Closing($Form_StoreValues_Closing)
$MainForm.remove_FormClosed($Form_Cleanup_FormClosed)
}
catch [Exception]
{ }
}

#----------------------------------------------
#region Generated Form Code
#----------------------------------------------
$MainForm.SuspendLayout()
$panel2.SuspendLayout()
$panel1.SuspendLayout()
#
# MainForm
#
$MainForm.Controls.Add($panel2)
$MainForm.Controls.Add($panel1)
$MainForm.Controls.Add($labelSecondsLeftToLogoff)
$MainForm.Controls.Add($labelTime)
$MainForm.Controls.Add($labelInOrderToApplySecuri)
$MainForm.AutoScaleDimensions = '6, 13'
$MainForm.AutoScaleMode = 'Font'
$MainForm.BackColor = 'White'
$MainForm.ClientSize = '600, 300'
$MainForm.MaximizeBox = $False
$MainForm.MinimizeBox = $False
$MainForm.Name = 'MainForm'
$MainForm.ShowIcon = $False
$MainForm.ShowInTaskbar = $False
$MainForm.StartPosition = 'CenterScreen'
$MainForm.Text = $MainFormTitle
$MainForm.TopMost = $False
$MainForm.add_Load($MainForm_Load)
$MainForm.Add_Closing({$_.Cancel = $true})
#
# Bottom Panel2 (Grey)
#
#$panel2.Controls.Add($ButtonCancel)
$panel2.Controls.Add($ButtonLogoffRemote)
$panel2.Controls.Add($ButtonLogoffLocal)
$panel2.Controls.Add($Logo)
$panel2.BackColor = 'ScrollBar'
$panel2.Location = '0, 235'
$panel2.Name = 'panel2'
$panel2.Size = '600, 65'
$panel2.TabIndex = 9
$panel2.add_Paint($panel2_Paint)
#
#Logo
#
$Logo.Width = 130
$Logo.Height = 65
$Logo.Width = 130
$Logo.Height = 65
$Logo.location = new-object system.drawing.point(1,1)
$Logo.ImageLocation = $LogoLocation
#
# ButtonCancel (Disable in live version)
<#
$ButtonCancel.Location = '70, 12'
$ButtonCancel.Name = 'ButtonCancel'
$ButtonCancel.Size = '77, 45'
$ButtonCancel.TabIndex = 7
$ButtonCancel.Text = 'Cancel'
$ButtonCancel.UseVisualStyleBackColor = $True
$ButtonCancel.add_Click($buttonCancel_Click)
#>
# ButtonLogoffRemote
# 
$ButtonLogoffRemote.Font = 'Microsoft Sans Serif, 9pt, style=Bold'
$ButtonLogoffRemote.Location = '385, 12'
$ButtonLogoffRemote.Name = 'ButtonSchedule'
$ButtonLogoffRemote.Size = '110, 45'
$ButtonLogoffRemote.TabIndex = 6
$ButtonLogoffRemote.Text = "Отдалечено отписване"
$ButtonLogoffRemote.UseVisualStyleBackColor = $True
$ButtonLogoffRemote.add_Click($ButtonLogOffRemote_Click)
#
# ButtonLogoffLocal
#
$ButtonLogoffLocal.Font = 'Microsoft Sans Serif, 9pt, style=Bold'
$ButtonLogoffLocal.Location = '500, 12'
$ButtonLogoffLocal.Name = 'ButtonRestartNow'
$ButtonLogoffLocal.Size = '95, 45'
$ButtonLogoffLocal.TabIndex = 0
$ButtonLogoffLocal.Text = "Отпиши този компютър"
$ButtonLogoffLocal.UseVisualStyleBackColor = $True
$ButtonLogoffLocal.add_Click($ButtonLogoffLocal_Click)
#
# Top Panel1 (Red)
#
$panel1.Controls.Add($labelITSystemsMaintenance)
$panel1.BackColor =   '255, 100, 100'
$panel1.Location = '0, 0'
$panel1.Name = 'panel1'
$panel1.Size = '600, 67'
$panel1.TabIndex = 8
#
# labelITSystemsMaintenance
#
$labelITSystemsMaintenance.Font = 'Microsoft Sans Serif, 16pt, style=Bold'
$labelITSystemsMaintenance.ForeColor = 'White'
$labelITSystemsMaintenance.Location = '11, 3'
$labelITSystemsMaintenance.Name = 'labelITSystemsMaintenance'
$labelITSystemsMaintenance.Size = '600, 60'
$labelITSystemsMaintenance.TabIndex = 1
$labelITSystemsMaintenance.Text = $WindowTitleMsg
$labelITSystemsMaintenance.TextAlign = 'MiddleLeft'
$labelITSystemsMaintenance.add_Click($labelITSystemsMaintenance_Click)
#
# labelSecondsLeftToLogoff
#
$labelSecondsLeftToLogoff.AutoSize = $True
$labelSecondsLeftToLogoff.Font = 'Microsoft Sans Serif, 11pt, style=Bold'
$labelSecondsLeftToLogoff.Location = '345, 198'
$labelSecondsLeftToLogoff.Name = 'labelSecondsLeftToRestart'
$labelSecondsLeftToLogoff.Size = '43, 15'
$labelSecondsLeftToLogoff.TabIndex = 5
$labelSecondsLeftToLogoff.Text = 'Ще бъдете отписани след:'
#
# labelTime
#
$labelTime.AutoSize = $True
$labelTime.Font = 'Microsoft Sans Serif, 18pt, style=Bold'
$labelTime.ForeColor = '192, 0, 0'
$labelTime.Location = '545, 191'
$labelTime.Name = 'labelTime'
$labelTime.Size = '43, 15'
$labelTime.TabIndex = 3
$labelTime.Text = '00:60'
$labelTime.TextAlign = 'MiddleCenter'
$labelTime.add_Click($labelTime_Click)
#
# labelInOrderToApplySecuri
# 
$labelInOrderToApplySecuri.Font = 'Microsoft Sans Serif, 11pt'
$labelInOrderToApplySecuri.Location = '12, 84'
$labelInOrderToApplySecuri.Name = 'labelInOrderToApplySecuri'
$labelInOrderToApplySecuri.Size = '580, 100'
$labelInOrderToApplySecuri.TabIndex = 2
$labelInOrderToApplySecuri.Text = $Body
#
# timerUpdate
#
$timerUpdate.add_Tick($timerUpdate_Tick)
$panel1.ResumeLayout()
$panel2.ResumeLayout()
$MainForm.ResumeLayout()

#----------------------------------------------

$InitialFormWindowState = $MainForm.WindowState
$MainForm.add_Load($Form_StateCorrection_Load)
$MainForm.add_FormClosed($Form_Cleanup_FormClosed)
$MainForm.add_Closing($Form_StoreValues_Closing)
return $MainForm.ShowDialog()
}
Main ($CommandLine)
}

else
{
	$Pivot = 1
	New-Item $UserFileLocation -type file -Force | Out-Null
	Add-Content $UserFileLocation $env:computername
	DO
	{
		if (!($UserFileLocation | Test-Path))
		{
			New-Item $UserFileLocation -type file -Force | Out-Null
			Add-Content $UserFileLocation $env:computername
		}
		$(Get-Item $UserFileLocation).lastwritetime=$(DATE)
		Start-Sleep -s 25
	}
	while ($Pivot -ne 0)
}
