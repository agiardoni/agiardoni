########################################################################################
#########################Autoelevation to administrator#################################
$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator
if ($myWindowsPrincipal.IsInRole($adminRole)){$Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition}
else{
    $newProcess = New-Object System.Diagnostics.ProcessStartInfo "PowerShell"
	$newProcess.Arguments = $myInvocation.MyCommand.Definition+"Administrator"
	$newProcess.Verb = "runas"
	[System.Diagnostics.Process]::Start($newProcess)
}

########################################################################################
################################DeclareObjectProject####################################
########################################################################################

$dir_temp = "C:\temp\"
$version_winplementator = "1.8.3"
$version_winplementator_full ="$version_winplementator.1.2021.12.20"
$File_wP = "winplementator-$version_winplementator.1.ps1"
$File_wP_conf = "wP.conf"
$PSHost = Get-Host
$PSWindow = $PSHost.UI.RawUI
#$PSWindow.CursorSize = 25
$PSWindow.WindowTitle = "wP $version_winplementator_full"
$NewSize_BufferSize = $PSWindow.BufferSize
$NewSize_BufferSize.Height = 80
$NewSize_BufferSize.Width = 470
$PSWindow.BufferSize = $NewSize_BufferSize
$NewSize_WindowSize = $PSWindow.WindowSize
$NewSize_WindowSize.Height = 80
$NewSize_WindowSize.Width = 470
$PSWindow.WindowSize = $NewSize_WindowSize

########################################################################################
###################################Function Logging#####################################
########################################################################################

if (!(Test-Path $dir_temp)){New-Item -ItemType directory -Path $dir_temp|Out-Null}
$LogFilePath = (Get-Date -UFormat "$dir_temp`wp_%Y-%m-%d.log.csv")

if ((Get-ChildItem -Path $dir_temp *.log.csv).count -gt "2"){
$file_to_delete = ((Get-ChildItem -Path $dir_temp *.log.csv).Name).Split('`n')[0]
Remove-Item -Force $dir_temp$file_to_delete
}

function Write-Log{
param (
    [Parameter(Mandatory)]
    [string]$Message,
    [Parameter()]
    $Severity = 1
)
switch ($Severity){
1{$Severity = "INFO   ";$foreground_color_log = "Green"}
2{$Severity = "WARNING";$foreground_color_log = "Yellow"}
3{$Severity = "ERROR  ";$foreground_color_log = "Red"}
}
$line = [pscustomobject]@{'DateTime' = (Get-Date -UFormat "[%Y-%m-%d %H:%m:%S]");'Severity' = $Severity;'Message' = $Message}
Write-Host (Get-Date -UFormat "[%Y-%m-%d %H:%m:%S] ")$severity' :'$Message -ForegroundColor $foreground_color_log
$line | Export-Csv -Path $LogFilePath -Append -NoTypeInformation -Delimiter ";"
}

########################################################################################
######################################Add Modules#######################################
########################################################################################

try{Add-Type -AssemblyName System.Windows.Forms,System.Drawing,mscorlib,System.Management.Automation}catch{Write-Log $_.Exception.Message}
$Icon = [system.drawing.icon]::ExtractAssociatedIcon($env:SystemRoot + "\System32\setupapi.dll")

########################################################################################
###################################DeclareObjectForm####################################
########################################################################################

$Form = New-Object Windows.Forms.Form
$TabControl = New-Object Windows.Forms.TabControl
$TabPageSecurity = New-Object Windows.Forms.TabPage
$TabPageSystem = New-Object Windows.Forms.TabPage
$TabPageNetwork = New-Object Windows.Forms.TabPage
$TabPageServices = New-Object Windows.Forms.TabPage
$TabPageMcAfee = New-Object Windows.Forms.TabPage
#$TabPageAgentHP = New-Object Windows.Forms.TabPage
$TabPageAgentDD = New-Object Windows.Forms.TabPage
#new#
$TabPageZabbix = New-Object Windows.Forms.TabPage
#####
$TabPageReporting = New-Object Windows.Forms.TabPage
$TabPageAbout = New-Object Windows.Forms.TabPage
$Button_close = New-Object Windows.Forms.Button
$Button_reset_conf = New-Object Windows.Forms.Button
$Button_restart = New-Object Windows.Forms.Button
$Button_logout = New-Object Windows.Forms.Button
$wshell = New-Object -ComObject Wscript.Shell
#define a tooltip object
$tooltip1 = New-Object System.Windows.Forms.ToolTip
<#
define a scriptblock to display the tooltip
add a _MouseHover event to display the corresponding tool tip
 e.g. $txtPath.add_MouseHover($ShowHelp)
 #>
$ShowHelp={
 #display popup help
    #each value is the name of a control on the form.
    
 Switch ($this.name) {
 "text1"  {$tip = "Inserire il nome host e confermare con il pulsante sotto"}
 "text2" {$tip = "Query Win32_OperatingSystem"}
 "textDD1" {$tip = "Inserire la descrizione del servizio operativo come da SA"}
        
 }
 $tooltip1.SetToolTip($this,$tip)
} #end ShowHelp

########################################################################################
###########################DeclareObjectForTabPageSecurity##############################
########################################################################################
$GroupBox_hardening = New-Object Windows.Forms.GroupBox
$Button_apply_hardening = New-Object Windows.Forms.Button
$Button_rollback_hardening = New-Object Windows.Forms.Button
$Label_hard = New-Object Windows.Forms.Label
$Button_iiscrypto = New-Object Windows.Forms.Button
$Label_iiscrypto = New-Object Windows.Forms.Label

########################################################################################
###########################DeclareObjectForTabPageSystemVmW#############################
########################################################################################
$GroupBox_VmW = New-Object Windows.Forms.GroupBox
$GroupBox_domain = New-Object Windows.Forms.GroupBox
$GroupBox_azure = New-Object Windows.Forms.GroupBox
$TextBox_hostname = New-Object Windows.Forms.TextBox
$DropDown_domains = New-Object Windows.Forms.ComboBox
$Label_Join = New-Object Windows.Forms.Label
$TextBox_username = New-Object Windows.Forms.TextBox
$TextBox_password = New-Object Windows.Forms.MaskedTextBox
$Button_changehn = New-Object Windows.Forms.Button
$Button_joindomain = New-Object Windows.Forms.Button
$Button_groups_and_user_add = New-Object Windows.Forms.Button
$Button_admin_changes = New-Object Windows.Forms.Button
$Button_regional_custom = New-Object Windows.Forms.Button
$Button_admin_home = New-Object Windows.Forms.Button
$Button_resize_disk = New-Object Windows.Forms.Button
###AZURE###
$Button_groups_and_user_add2 = New-Object Windows.Forms.Button
$Button_admin_changes2 = New-Object Windows.Forms.Button
$Button_regional_custom2 = New-Object Windows.Forms.Button
$Button_admin_home2 = New-Object Windows.Forms.Button

########################################################################################
###########################DeclareObjectForTabPageNetwork###############################
########################################################################################
$erog_name_nic = $env:COMPUTERNAME+'_E1'
$erogbal_name_nic = $env:COMPUTERNAME+'_EB1'
$mgmt_name_nic = $env:COMPUTERNAME+'_M1'
$mb_name_nic = $env:COMPUTERNAME+'_MB1'
$internal_name_nic = $env:COMPUTERNAME+'_I1'
$Button_refresh_list_nic = New-Object Windows.Forms.Button
$Label_currentnics = New-Object Windows.Forms.Label
$GroupBox_set_ipaddr = New-Object Windows.Forms.GroupBox
$Label_ipaddr = New-Object Windows.Forms.Label
$TextBox_ipaddr1 = New-Object Windows.Forms.TextBox
$TextBox_ipaddr2 = New-Object Windows.Forms.TextBox
$TextBox_ipaddr3 = New-Object Windows.Forms.TextBox
$TextBox_ipaddr4 = New-Object Windows.Forms.TextBox
$Label_Netmask = New-Object Windows.Forms.Label
$DropDown_Netmask = New-Object Windows.Forms.ComboBox
$Label_gw = New-Object Windows.Forms.Label
$TextBox_gw1 = New-Object Windows.Forms.TextBox
$TextBox_gw2 = New-Object Windows.Forms.TextBox
$TextBox_gw3 = New-Object Windows.Forms.TextBox
$TextBox_gw4 = New-Object Windows.Forms.TextBox
$Button_setipaddr = New-Object Windows.Forms.Button
$DropDown_listnics = New-Object Windows.Forms.ComboBox
$Button_change_name_nic = New-Object Windows.Forms.Button
$Label_modifiednamenic = New-Object Windows.Forms.Label
$DropDown_modifiednamenic = New-Object Windows.Forms.ComboBox
$Button_binding_nic = New-Object Windows.Forms.Button
$Button_reset_nonpresent_nic = New-Object Windows.Forms.Button
$Button_setdhcp = New-Object Windows.Forms.Button
$Label_notice_dns = New-Object Windows.Forms.Label
$GroupBox_dns = New-Object Windows.Forms.GroupBox
$Button_dns_prod_nord = New-Object Windows.Forms.Button
$Button_dns_prod_center = New-Object Windows.Forms.Button
$Button_dns_prod_south = New-Object Windows.Forms.Button
$Button_dns_cert = New-Object Windows.Forms.Button
$Button_dns_svil = New-Object Windows.Forms.Button
$Button_dns_mgmt = New-Object Windows.Forms.Button

########################################################################################
##########################DeclareObjectForTabPageServices###############################
########################################################################################
$GroupBox_services = New-Object Windows.Forms.GroupBox
$Button_firewall_disable = New-Object Windows.Forms.Button
$Button_rdp_enable = New-Object Windows.Forms.Button
$GroupBox_evf = New-Object Windows.Forms.GroupBox
$Button_evf_to1 = New-Object Windows.Forms.Button
$Button_evf_to2 = New-Object Windows.Forms.Button
$Button_evf_po = New-Object Windows.Forms.Button
$Button_evf_ro = New-Object Windows.Forms.Button
$Button_evf_co = New-Object Windows.Forms.Button
$Label_to1 = New-Object Windows.Forms.Label
$Label_to2 = New-Object Windows.Forms.Label


########################################################################################
##########################DeclareObjectForTabPageMcAfee#################################
########################################################################################

$dir_McAfee= $dir_temp+'McAfee'
$GroupBox_McAfee = New-Object Windows.Forms.GroupBox
$GroupBox_agent_McAfee = New-Object Windows.Forms.GroupBox
$Button_agent_McAfee_svil = New-Object Windows.Forms.Button
$Button_agent_McAfee_cert = New-Object Windows.Forms.Button
$Button_agent_McAfee_prod = New-Object Windows.Forms.Button
$Label_engine_McAfee = New-Object Windows.Forms.Label
$Button_engine_McAfee = New-Object Windows.Forms.Button

########################################################################################
###########################DeclareObjectForTabPageAgentHP###############################
########################################################################################
<#$Button_configure_hostsfile = New-Object Windows.Forms.Button
$DropDown_listip = New-Object Windows.Forms.ComboBox
$Label_selectip_agenthp = New-Object Windows.Forms.Label
$Button_agenthp_install = New-Object Windows.Forms.Button
$GroupBox_agenthp_configure = New-Object Windows.Forms.GroupBox
$Button_agenthp_configure = New-Object Windows.Forms.Button
$Label_agenthp_configure_progressbar = New-Object Windows.Forms.Label
$progressBar_agenthp_configure = New-Object Windows.Forms.ProgressBar
$oainstallFile = "C:\Temp\Agent_HP\INSTDIR\oainstall.vbs"
$GroupBox_agenthp_verify = New-Object Windows.Forms.GroupBox
$Button_agenthp_verify = New-Object Windows.Forms.Button
$RichTextBox_agenthp_verify = New-Object Windows.Forms.RichTextBox#>

########################################################################################
###########################DeclareObjectForTabPageZabbix###############################
########################################################################################

$Zabbixprod_path = "c:\temp\zabbix\prod\"
$Zabbixcert_path = "c:\temp\zabbix\cert\"
$Button_zabbix_prod_install = New-Object Windows.Forms.Button
$Button_zabbix_cert_install = New-Object Windows.Forms.Button
$GroupBox_zabbix = New-Object Windows.Forms.GroupBox
$Label_zabbix_prod_install = New-Object Windows.Forms.Label
$Label_zabbix_cert_install = New-Object Windows.Forms.Label
$Button_zabbix_verify = New-Object Windows.Forms.Button

########################################################################################
###########################DeclareObjectForTabPageAgentDD###############################
########################################################################################
$Button_configure_proxyprod = New-Object Windows.Forms.Button
$Button_configure_proxycert = New-Object Windows.Forms.Button
$Button_AgentDD_install = New-Object Windows.Forms.Button
$Button_checkproxycert = New-Object Windows.Forms.Button
$Button_checkproxyprod = New-Object Windows.Forms.Button
$Button_restart_AgentDD = New-Object Windows.Forms.Button
$Button_DDgui = New-Object Windows.Forms.Button
$Button_removeDD = New-Object Windows.Forms.Button
#$Button_stop_AgentDD = New-Object Windows.Forms.Button
#$DropDown_listip = New-Object Windows.Forms.ComboBox
$Label_TAG_Service = New-Object Windows.Forms.Label
$Label_TAG_Site = New-Object Windows.Forms.Label
$Label_EnvTAG = New-Object Windows.Forms.Label
$Label_TAG_ENV = New-Object Windows.Forms.Label
$Label_TAG_info = New-Object Windows.Forms.Label
$Label_TAG_Type = New-Object Windows.Forms.Label
$Label_TAG_Availability = New-Object Windows.Forms.Label
$Label_TAG_Role = New-Object Windows.Forms.Label
$TextBox_Service = New-Object Windows.Forms.TextBox
$GroupBox_AgentDD_TAG = New-Object Windows.Forms.GroupBox
$DropDown_EnvTAG = New-Object Windows.Forms.ComboBox
$DropDown_SiteTAG = New-Object Windows.Forms.ComboBox
$DropDown_TypeTAG = New-Object Windows.Forms.ComboBox
$DropDown_AvailabilityTAG = New-Object Windows.Forms.ComboBox
$DropDown_RoleTAG = New-Object Windows.Forms.ComboBox
#$Button_AgentDD_configure = New-Object Windows.Forms.Button
#$GroupBox_AgentDD_verify = New-Object Windows.Forms.GroupBox
#$Button_AgentDD_verify = New-Object Windows.Forms.Button
#$RichTextBox_AgentDD_verify = New-Object Windows.Forms.RichTextBox

########################################################################################
##########################DeclareObjectForTabPageReporting##############################
########################################################################################
$File_R4C_name = (Get-Date -UFormat "R4C_$env:COMPUTERNAME`_%Y-%m-%d.csv")
$File_R4C = "$dir_temp$File_R4C_name"
$File_R4C_htm = (Get-Date -UFormat "R4C_$env:COMPUTERNAME`_%Y-%m-%d.htm")
$File_R4C_web = "$dir_temp$File_R4C_htm"
$GroupBox_temp_dir = New-Object Windows.Forms.GroupBox
$GroupBox_R4C = New-Object Windows.Forms.GroupBox
$Button_RunReport = New-Object Windows.Forms.Button
$Button_ViewReport = New-Object Windows.Forms.Button
$Button_clean_temp = New-Object Windows.Forms.Button
$Button_open_temp = New-Object Windows.Forms.Button
$progressBar_R4C = New-Object Windows.Forms.ProgressBar
$GroupBox_R4C_controls = New-Object Windows.Forms.GroupBox
$Label_Report_summary = New-Object Windows.Forms.Label
$Label_Report_system = New-Object Windows.Forms.Label
$Label_Report_network = New-Object Windows.Forms.Label
$Label_Report_SCCM = New-Object Windows.Forms.Label
$Label_Report_services = New-Object Windows.Forms.Label
$Label_Report_agenthp = New-Object Windows.Forms.Label
$Label_Report_McAfee = New-Object Windows.Forms.Label

########################################################################################
############################DeclareObjectForTabPageAbout################################
########################################################################################
$Label_about = New-Object Windows.Forms.Label
$Button_unused = New-Object Windows.Forms.Button
$Button_checkversion = New-Object Windows.Forms.Button

########################################################################################
#######################################FUNCTIONS########################################
########################################################################################

########################################################################################
########################File configuration to do/done actions###########################
########################################################################################

if (!(Test-Path $dir_temp/$File_wP_conf)){New-Item -ItemType File -Path $dir_temp -Name $File_wP_conf|Out-Null}
else{foreach($Buttonsdone in (Get-Content $dir_temp/$File_wP_conf)){Invoke-Expression $Buttonsdone}}

function write-tofile-conf(){
param([Parameter(Mandatory)][string]$NameButton)
ac $dir_temp/$File_wP_conf "`$$NameButton.BackColor = `"Green`""
Invoke-Expression (Get-Content $dir_temp/$File_wP_conf|Select-Object -Last 1)
}

########################################################################################
#############################Function Selection features################################
########################################################################################

function selection-fromdomain{
try{
switch ((gwmi WIN32_ComputerSystem).Domain){
    rete.poste {$Button_dns_prod_south.Enabled = $false
    $Button_dns_cert.Enabled = $false
    $Button_dns_svil.Enabled = $false
    $Button_agent_McAfee_svil.Enabled = $false
    $Button_agent_McAfee_cert.Enabled = $false}

    retecert.postecert {$Button_dns_prod_nord.Enabled = $false
    $Button_dns_prod_center.Enabled = $false
    $Button_dns_prod_south.Enabled = $false
    $Button_dns_svil.Enabled = $false
    $Button_agent_McAfee_svil.Enabled = $false
    $Button_agent_McAfee_prod.Enabled = $false}

    rete.testposte {$Button_dns_prod_nord.Enabled = $false
    $Button_dns_prod_center.Enabled = $false
    $Button_dns_prod_south.Enabled = $false
    $Button_dns_cert.Enabled = $false
    $Button_agent_McAfee_cert.Enabled = $false
    $Button_agent_McAfee_prod.Enabled = $false
    $TabPageAgentHP.Enabled = $false}

}
}catch{Write-Log $_.Exception.Message -Severity 3}
}

########################################################################################
#################################functions TabPageSecurity##############################
########################################################################################
function iiscrypto()
{
	try
	{
		cmd /c C:\Temp\bin\IISCrypto.exe
		Write-Log "IIS CRYPTO TOOL avviato"
	}
	catch { Write-Log $_.Exception.Message -Severity 3 }
}

function apply-hardening-policy{
try{
REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\EventLog\Security"                /v MaxSize                   /t REG_DWORD /d 20971520 /f
REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters"          /v restrictnullsessaccess    /t REG_DWORD /d 1        /f
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\policies\system"          /v dontdisplaylastusername   /t REG_DWORD /d 1        /f
REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v ClearPageFileAtShutdown   /t REG_DWORD /d 1        /f
REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa"                               /v RestrictAnonymous         /t REG_DWORD /d 1        /f
REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa"                               /v everyoneincludesanonymous /t REG_DWORD /d 1        /f
REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa"                               /v disabledomaincreds		 /t REG_DWORD /d 1        /f
REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters"                /v DisabledComponents        /t REG_DWORD /d 255      /f
##Hardening##
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" 			/v ConsentPromptBehaviorAdmin /t REG_DWORD /d 00000000 /f
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" 			/v EnableLUA /t REG_DWORD /d 00000000 /f
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" 			/v EnableSecureUIAPaths /t REG_DWORD /d 00000000 /f
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" 			/v EnableInstallerDetection /t REG_DWORD /d 00000000 /f
##CortanaFIX##
REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\WMI\Autologger\EventLog-Application\{315a8872-923e-4ea2-9889-33cd4754bf64}" /v Enabled /t REG_DWORD /d 00000000 /f
wevtutil cl application
		####new fix TLS and Cipher#####
		###DISABLE TLS1.0###
		New-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server' -Force | Out-Null
		New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server' -name 'Enabled' -value '0' -PropertyType 'DWord' -Force | Out-Null
		New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server' -name 'DisabledByDefault' -value 1 -PropertyType 'DWord' -Force | Out-Null
		New-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client' -Force | Out-Null
		New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client' -name 'Enabled' -value '0' -PropertyType 'DWord' -Force | Out-Null
		New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client' -name 'DisabledByDefault' -value 1 -PropertyType 'DWord' -Force | Out-Null
		Write-Host 'TLS 1.0 has been disabled.'
		###DISABLE TLS1.1###
		New-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server' -Force | Out-Null
		New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server' -name 'Enabled' -value '0' -PropertyType 'DWord' -Force | Out-Null
		New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server' -name 'DisabledByDefault' -value 1 -PropertyType 'DWord' -Force | Out-Null
		New-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client' -Force | Out-Null
		New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client' -name 'Enabled' -value '0' -PropertyType 'DWord' -Force | Out-Null
		New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client' -name 'DisabledByDefault' -value 1 -PropertyType 'DWord' -Force | Out-Null
		Write-Host 'TLS 1.1 has been disabled.'
		###DISABLE SSL2 SSL3###
		New-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Server' -Force | Out-Null
		New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Server' -name 'Enabled' -value '0' -PropertyType 'DWord' -Force | Out-Null
		New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Server' -name 'DisabledByDefault' -value 1 -PropertyType 'DWord' -Force | Out-Null
		New-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Client' -Force | Out-Null
		New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Client' -name 'Enabled' -value '0' -PropertyType 'DWord' -Force | Out-Null
		New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Client' -name 'DisabledByDefault' -value 1 -PropertyType 'DWord' -Force | Out-Null
		Write-Host 'SSL 2.0 has been disabled.'
		###ENABLE TLS 1.2###
		New-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server' -Force | Out-Null
		New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server' -name 'Enabled' -value '1' -PropertyType 'DWord' -Force | Out-Null
		New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server' -name 'DisabledByDefault' -value 0 -PropertyType 'DWord' -Force | Out-Null
		New-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client' -Force | Out-Null
		New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client' -name 'Enabled' -value '1' -PropertyType 'DWord' -Force | Out-Null
		New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client' -name 'DisabledByDefault' -value 0 -PropertyType 'DWord' -Force | Out-Null
		Write-Host 'TLS 1.2 has been enabled.'
		##Ciphers RC2 and RC4##
		REG ADD "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\NULL" 			/v Enabled /t REG_DWORD /d 00000000 /f
		REG ADD "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\DES 56/56" 		/v Enabled /t REG_DWORD /d 00000000 /f
		REG ADD "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC2 40/128" 		/v Enabled /t REG_DWORD /d 00000000 /f
		REG ADD "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC2 56/128" 		/v Enabled /t REG_DWORD /d 00000000 /f
		REG ADD "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC2 128/128" 		/v Enabled /t REG_DWORD /d 00000000 /f
		REG ADD "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 40/128" 		/v Enabled /t REG_DWORD /d 00000000 /f
		REG ADD "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 56/128" 		/v Enabled /t REG_DWORD /d 00000000 /f
		REG ADD "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 64/128" 		/v Enabled /t REG_DWORD /d 00000000 /f
		REG ADD "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 128/128" 		/v Enabled /t REG_DWORD /d 00000000 /f
		
#		###DISABLE CHIPER PROTOCOL###
#		Disable-TlsCipherSuite -Name "TLS_DHE_RSA_WITH_AES_256_CBC_SHA"
#		Disable-TlsCipherSuite -Name "TLS_DHE_RSA_WITH_AES_128_CBC_SHA"
#		Disable-TlsCipherSuite -Name "TLS_RSA_WITH_AES_256_GCM_SHA384"
#		Disable-TlsCipherSuite -Name "TLS_RSA_WITH_AES_128_GCM_SHA256"
#		Disable-TlsCipherSuite -Name "TLS_RSA_WITH_AES_256_CBC_SHA256"
#		Disable-TlsCipherSuite -Name "TLS_RSA_WITH_AES_128_CBC_SHA256"
#		Disable-TlsCipherSuite -Name "TLS_RSA_WITH_AES_256_CBC_SHA"
#		Disable-TlsCipherSuite -Name "TLS_RSA_WITH_AES_128_CBC_SHA"
#		Disable-TlsCipherSuite -Name "TLS_RSA_WITH_3DES_EDE_CBC_SHA"
#		Disable-TlsCipherSuite -Name "TLS_DHE_DSS_WITH_AES_256_CBC_SHA256"
#		Disable-TlsCipherSuite -Name "TLS_DHE_DSS_WITH_AES_128_CBC_SHA256"
#		Disable-TlsCipherSuite -Name "TLS_DHE_DSS_WITH_AES_256_CBC_SHA"
#		Disable-TlsCipherSuite -Name "TLS_DHE_DSS_WITH_AES_128_CBC_SHA"
#		Disable-TlsCipherSuite -Name "TLS_DHE_DSS_WITH_3DES_EDE_CBC_SHA"
#		Disable-TlsCipherSuite -Name "TLS_RSA_WITH_RC4_128_SHA"
#		Disable-TlsCipherSuite -Name "TLS_RSA_WITH_RC4_128_MD5"
#		Disable-TlsCipherSuite -Name "TLS_RSA_WITH_NULL_SHA256"
#		Disable-TlsCipherSuite -Name "TLS_RSA_WITH_NULL_SHA"
#		Disable-TlsCipherSuite -Name "TLS_PSK_WITH_AES_256_GCM_SHA384"
#		Disable-TlsCipherSuite -Name "TLS_PSK_WITH_AES_128_GCM_SHA256"
#		Disable-TlsCipherSuite -Name "TLS_PSK_WITH_AES_256_CBC_SHA384"
#		Disable-TlsCipherSuite -Name "TLS_PSK_WITH_AES_128_CBC_SHA256"
#		Disable-TlsCipherSuite -Name "TLS_PSK_WITH_NULL_SHA384"
#		Disable-TlsCipherSuite -Name "TLS_PSK_WITH_NULL_SHA256"
#		Write-Host 'Chiper Protocol Disable'
###PAGESYS###
$computersys = Get-WmiObject Win32_ComputerSystem -EnableAllPrivileges;
$computersys.AutomaticManagedPagefile = $False;
$computersys.Put();
$pagefile = Get-WmiObject -Query "Select * From Win32_PageFileSetting Where Name like '%pagefile.sys'";
$pagefile.InitialSize = 4096;
$pagefile.MaximumSize = 4096;
$pagefile.Put();
Write-Log -Message "SWAP settata a 4GB"
$wshell.Popup("E' altamente consigliato il riavvio del server",0,"Warning")
Write-Log "Hardening completato"
}catch{Write-Log $_.Exception.Message -Severity 3}
}


########################################################################################
#################################functions TabPageSystemVmW#############################
########################################################################################

function Rename-hostname{
$Value_HostnameChange = $TextBox_hostname.Text
if ($TextBox_hostname.Text -ne $env:COMPUTERNAME){
    Write-Log -Message "Hostname modificato da $env:COMPUTERNAME in $Value_HostnameChange" -Severity 2
    try{Rename-Computer -NewName $TextBox_hostname.Text}catch{Write-Log $_.Exception.Message -Severity 3}
    $wshell.Popup("E' altamente consigliabile il riavvio",0,"Warning")
    }
else{
    Write-Log -Message "Hostname non modificato" -Severity 3
    $wshell.Popup("Hostname non modificato",0,"Error")
}
}

function get-listdomains{
try{
$DropDown_domains.Items.Clear()
$list_domains = @('rete.poste',
'retecert.postecert',
'rete.testposte')
foreach($domains in $list_domains){$DropDown_domains.Items.add($domains)}
}catch{Write-Log $_.Exception.Message -Severity 3}
}
########OLD#########
#function get-listdomains{
#try{
#$DropDown_domains.Items.Clear()
#$list_domains = @('rete.poste',
#'retecert.postecert',
#'rete.testposte','posteitaliane.onmicrosoft.com','retecert.onmicrosoft.com','retetest.onmicrosoft.com')
#foreach($domains in $list_domains){$DropDown_domains.Items.add($domains)}
#}catch{Write-Log $_.Exception.Message -Severity 3}
#}
####################
function join-domain{
try{
if ($DropDown_domains.Text -ne (gwmi WIN32_ComputerSystem).Domain){
    $domain = $DropDown_domains.Text
    $password = $TextBox_password.text | ConvertTo-SecureString -asPlainText -Force
    $username = $TextBox_username.text
    $credential = New-Object System.Management.Automation.PSCredential $domain\$username,$password
    try{Add-Computer -DomainName $domain -Credential $credential -Force -PassThru}
    catch{Write-Log -Message $_.Exception.Message -Severity 3;$errors_log = $false}
    if ($errors_log){
    Write-Log -Message "Join effettuata nel dominio $domain"
    $wshell.Popup("Join effettuata",0,"Warning")
    $wshell.Popup("E' altamente consigliato il riavvio del server",0,"Warning")
    selection-fromdomain
    }
    }
else{$wshell.Popup("Dominio non modificato",0,"Error")}
}catch{Write-Log $_.Exception.Message -Severity 3}
}

function Rename-guest{
try{
$NameGSTSRPI = "GSTSRPI"
$UserGSTSRPI = Get-WmiObject -Class Win32_UserAccount -Filter "LocalAccount='$True'"|Select-String -Pattern 'GSTSRPI'
If ($UserGSTSRPI -NE $Null){Write-Log -Message "Guest già  rinominato" -Severity 2}
else{
    $guest_ren=[adsi]"WinNT://./Guest,user"
    $guest_ren.psbase.rename("GSTSRPI")
    $guest_ren.SetInfo()
    Write-Log -Message "Guest Rinominato"
    }
}catch{Write-Log $_.Exception.Message -Severity 3}
}

function Rename-administrator{
try{
$NameSfiadmsm = "Sfiadmsm"
$UserSfiadmsm = Get-WmiObject -Class Win32_UserAccount -Filter "LocalAccount='$True'"|Select-String -Pattern 'Sfiadmsm'|select-string -NotMatch Sfiadmsm1
If ($UserSfiadmsm -NE $Null){Write-Log -Message "Administrator già  rinominato" -Severity 2}
elseif ($UserPosteAdmin -NE $Null){
    $admin=[adsi]"WinNT://./PosteAdmin,user"
    $admin.psbase.rename("Sfiadmsm")
    $admin.SetInfo()
    $admin=[adsi]"WinNT://./Sfiadmsm,user"
    $admin.psbase.invoke("SetPassword","Pegasus1")
    $flag = $admin.UserFlags = 65536
    $admin.SetInfo()
    Write-Log -Message "PosteAdmin Rinominato"
    }
else{
    $admin=[adsi]"WinNT://./Administrator,user"
    $admin.psbase.rename("Sfiadmsm")
    $admin.SetInfo()
    $admin=[adsi]"WinNT://./Sfiadmsm,user"
    $admin.psbase.invoke("SetPassword","Pegasus1")
    $flag = $admin.UserFlags = 65536
    $admin.SetInfo()
    Write-Log -Message "Administrator Rinominato"
    }
Rename-guest
}catch{Write-Log $_.Exception.Message -Severity 3}
}

function create-sfiadmsm1{
try{
$NameSfiadmsm1 = "Sfiadmsm1"
$UserSfiadmsm1 = Get-WmiObject -Class Win32_UserAccount -Filter "LocalAccount='$True'"|Select-String -Pattern 'Sfiadmsm1'
If ($UserSfiadmsm1 -NE $Null){Write-Log -Message "Sfiadmsm1 già  creato" -Severity 2}
else{
    invoke-command {net user Sfiadmsm1 Pegasus1 /ADD /FULLNAME:"Sfiadmsm1"}
    invoke-command {net localgroup administrators Sfiadmsm1 /add}
    $admin1=[adsi]"WinNT://./Sfiadmsm1,user"
    $flag = $admin1.UserFlags = 65536
    $admin1.SetInfo()
    Write-Log -Message "Sfiadmsm1 creato"
    }
}catch{Write-Log $_.Exception.Message -Severity 3}
}

function remove-home-admin{
try{
rundll32.exe sysdm.cpl,EditUserProfiles
}catch{Write-Log $_.Exception.Message -Severity 3}
}

function add-group-admins{
$admins_group=[adsi]"WinNT://./Administrators,group"
$Domain = (gwmi WIN32_ComputerSystem).Domain
switch ($Domain){
    rete.poste {
    try{
    $GroupAccount1 = "WinNT://$Domain/implementazione sistemi,group"
    $GroupAccount2 = "WinNT://$Domain/serverfarmintel,group"
    $GroupAccount3 = "WinNT://$Domain/wintelsistemioperativi,group"
	$GroupAccount4 = "WinNT://$Domain/srv_versic,user"
	$GroupAccount5 = "WinNT://$Domain/ucmdb,user"
    $admins_group.Add($GroupAccount1)}catch{Write-Log $_.Exception.Message -Severity 3}
    try{$admins_group.Add($GroupAccount2)}catch{Write-Log $_.Exception.Message -Severity 3}
    try{$admins_group.Add($GroupAccount3)}catch{Write-Log $_.Exception.Message -Severity 3}
	try{$admins_group.Add($GroupAccount4)}catch{Write-Log $_.Exception.Message -Severity 3}
	try{$admins_group.Add($GroupAccount4)}catch{Write-Log $_.Exception.Message -Severity 3}
	try{$admins_group.Add($GroupAccount5)}catch{Write-Log $_.Exception.Message -Severity 3}
			
	Write-Log -Message "Gruppi di produzione e user Versic aggiunti"
    $wshell.Popup("Gruppi di produzione e user Versic aggiunti",0,"Warning")
    create-sfiadmsm1
    }
    rete.testposte{
    try{
    $GroupAccount1 = "WinNT://$Domain/implementazione sistemi,group"
	$GroupAccount4 = "WinNT://$Domain/srv_versic,user"
    $admins_group.Add($GroupAccount1)}catch{Write-Log $_.Exception.Message -Severity 3}
	try{$admins_group.Add($GroupAccount4)}catch{Write-Log $_.Exception.Message -Severity 3}
    Write-Log -Message "Gruppo di sviluppo aggiunto"
    $wshell.Popup("Gruppo di sviluppo e user Versic aggiunti",0,"Warning")
    }
	retecert.postecert{
	try{
	$GroupAccount1 = "WinNT://$Domain/implementazione sistemi,group"
	$GroupAccount5 = "WinNT://$Domain/ucmdb,user"
	$admins_group.Add($GroupAccount1)}catch{Write-Log $_.Exception.Message -Severity 3}
	try { $admins_group.Add($GroupAccount5)}catch{Write-Log $_.Exception.Message -Severity 3}
	Write-Log -Message "Gruppo di certificazione aggiunto"
	$wshell.Popup("Gruppo di certificazione e user aggiunti", 0, "Warning")
		}
	}
}

function Regional-custom{
try{
$UserLanguageList = New-WinUserLanguageList -Language "en-US"
$UserLanguageList[0].InputMethodTips.Clear()
$UserLanguageList[0].InputMethodTips.Add('0409:00000410')
Set-WinUserLanguageList -LanguageList $UserLanguageList -Force
Set-WinSystemLocale en-US
Set-WinHomeLocation -GeoId 244
Set-Culture en-US
tzutil.exe /s "W. Europe Standard Time"
Rundll32 Shell32.dll,Control_RunDLL Intl.cpl,`,2
Write-Log -Message "Parametri regionali applicati"
}catch{Write-Log $_.Exception.Message -Severity 3}
}

function resize-systemdisk {
try{
$size = (Get-PartitionSupportedSize -DriveLetter C)
$actualsize = (Get-Partition -DriveLetter C)
$size = $size.SizeMax
$actualsize = $actualsize.size
$difference = ( $size - $actualsize)
if ($difference -lt 1050000 ){
    Write-Log -Message "Disco già  ridimensionato" -Severity 2
    $Button_resize_disk.Text = "Disco già ridimensionato"
    }
else{
    Resize-Partition -DriveLetter C -Size $size
    Write-Log -Message "Resize disco di sistema effettuata"
    $wshell.Popup("Resize disco di sistema effettuata",0,"Warning")
    }
}catch{Write-Log $_.Exception.Message -Severity 3}
}

########################################################################################
#################################functions TabPageSystemAzure###########################
########################################################################################

function Rename-guest{
try{
$NameGSTSRPI = "GSTSRPI"
$UserGSTSRPI = Get-WmiObject -Class Win32_UserAccount -Filter "LocalAccount='$True'"|Select-String -Pattern 'GSTSRPI'
If ($UserGSTSRPI -NE $Null){Write-Log -Message "Guest già  rinominato" -Severity 2}
else{
    $guest_ren=[adsi]"WinNT://./Guest,user"
    $guest_ren.psbase.rename("GSTSRPI")
    $guest_ren.SetInfo()
    Write-Log -Message "Guest Rinominato"
    }
}catch{Write-Log $_.Exception.Message -Severity 3}
}

function Rename-administrator{
try{
$NameSfiadmsm = "Sfiadmsm"
$UserSfiadmsm = Get-WmiObject -Class Win32_UserAccount -Filter "LocalAccount='$True'"|Select-String -Pattern 'Sfiadmsm'|select-string -NotMatch Sfiadmsm1
If ($UserSfiadmsm -NE $Null){Write-Log -Message "Administrator già  rinominato" -Severity 2}
elseif ($UserPosteAdmin -NE $Null){
    $admin=[adsi]"WinNT://./PosteAdmin,user"
    $admin.psbase.rename("Sfiadmsm")
    $admin.SetInfo()
    $admin=[adsi]"WinNT://./Sfiadmsm,user"
    $admin.psbase.invoke("SetPassword","Pegasus1")
    $flag = $admin.UserFlags = 65536
    $admin.SetInfo()
    Write-Log -Message "PosteAdmin Rinominato"
    }
else{
    $admin=[adsi]"WinNT://./Administrator,user"
    $admin.psbase.rename("Sfiadmsm")
    $admin.SetInfo()
    $admin=[adsi]"WinNT://./Sfiadmsm,user"
    $admin.psbase.invoke("SetPassword","Pegasus1")
    $flag = $admin.UserFlags = 65536
    $admin.SetInfo()
    Write-Log -Message "Administrator Rinominato"
    }
Rename-guest
}catch{Write-Log $_.Exception.Message -Severity 3}
}

function create-sfiadmsm1{
try{
$NameSfiadmsm1 = "Sfiadmsm1"
$UserSfiadmsm1 = Get-WmiObject -Class Win32_UserAccount -Filter "LocalAccount='$True'"|Select-String -Pattern 'Sfiadmsm1'
If ($UserSfiadmsm1 -NE $Null){Write-Log -Message "Sfiadmsm1 già  creato" -Severity 2}
else{
    invoke-command {net user Sfiadmsm1 Pegasus1 /ADD /FULLNAME:"Sfiadmsm1"}
    invoke-command {net localgroup administrators Sfiadmsm1 /add}
    $admin1=[adsi]"WinNT://./Sfiadmsm1,user"
    $flag = $admin1.UserFlags = 65536
    $admin1.SetInfo()
    Write-Log -Message "Sfiadmsm1 creato"
    }
}catch{Write-Log $_.Exception.Message -Severity 3}
}

function remove-home-admin{
try{
rundll32.exe sysdm.cpl,EditUserProfiles
}catch{Write-Log $_.Exception.Message -Severity 3}
}

function add-group-admins{
$admins_group=[adsi]"WinNT://./Administrators,group"
$Domain = (gwmi WIN32_ComputerSystem).Domain
switch ($Domain){
    rete.poste {
    try{
    $GroupAccount1 = "WinNT://$Domain/implementazione sistemi,group"
    $GroupAccount2 = "WinNT://$Domain/serverfarmintel,group"
    $GroupAccount3 = "WinNT://$Domain/wintelsistemioperativi,group"
	$GroupAccount4 = "WinNT://$Domain/srv_versic,user"
    $admins_group.Add($GroupAccount1)}catch{Write-Log $_.Exception.Message -Severity 3}
    try{$admins_group.Add($GroupAccount2)}catch{Write-Log $_.Exception.Message -Severity 3}
    try{$admins_group.Add($GroupAccount3)}catch{Write-Log $_.Exception.Message -Severity 3}
	try{$admins_group.Add($GroupAccount4)}catch{Write-Log $_.Exception.Message -Severity 3}
    Write-Log -Message "Gruppi di produzione e user Versic aggiunti"
    $wshell.Popup("Gruppi di produzione e user Versic aggiunti",0,"Warning")
    create-sfiadmsm1
    }
    rete.testposte{
    try{
    $GroupAccount1 = "WinNT://$Domain/implementazione sistemi,group"
	$GroupAccount4 = "WinNT://$Domain/srv_versic,user"
    $admins_group.Add($GroupAccount1)}catch{Write-Log $_.Exception.Message -Severity 3}
	try{$admins_group.Add($GroupAccount4)}catch{Write-Log $_.Exception.Message -Severity 3}
    Write-Log -Message "Gruppo di sviluppo e user Versic aggiunti"
    $wshell.Popup("Gruppo di sviluppo e user Versic aggiunti",0,"Warning")
    }
    retecert.postecert{
    try{
    $GroupAccount1 = "WinNT://$Domain/implementazione sistemi,group"
	$GroupAccount2 = "WinNT://$Domain/serverfarmintel,group"
    $GroupAccount3 = "WinNT://$Domain/wintelsistemioperativi,group"
	$GroupAccount4 = "WinNT://$Domain/srv_versic,user"
    $admins_group.Add($GroupAccount1)}catch{Write-Log $_.Exception.Message -Severity 3}
	try{$admins_group.Add($GroupAccount4)}catch{Write-Log $_.Exception.Message -Severity 3}
    Write-Log -Message "Gruppo di Certificazione e user Versic aggiunti"
    $wshell.Popup("Gruppo di Certificazione e user Versic aggiunti",0,"Warning")
    }
#    retecert.onmicrosoft.com{$wshell.Popup("Nessun Gruppo aggiunto`nper retecert.postecert non necessario",0,"Warning")}
#    WORKGROUP{$wshell.Popup("Nessun Gruppo aggiunto`nFare prima la JOIN a dominio",0,"Warning")}
#    default {$wshell.Popup("Nessun Gruppo aggiunto`ndominio o WORKGROUP non previsto",0,"Warning")}
}
}

function Regional-custom{
try{
$UserLanguageList = New-WinUserLanguageList -Language "en-US"
$UserLanguageList[0].InputMethodTips.Clear()
$UserLanguageList[0].InputMethodTips.Add('0409:00000410')
Set-WinUserLanguageList -LanguageList $UserLanguageList -Force
Set-WinSystemLocale en-US
Set-WinHomeLocation -GeoId 244
Set-Culture en-US
tzutil.exe /s "W. Europe Standard Time"
Rundll32 Shell32.dll,Control_RunDLL Intl.cpl,`,2
Write-Log -Message "Parametri regionali applicati"
}catch{Write-Log $_.Exception.Message -Severity 3}
}

########################################################################################
################################functions TabPageNetwork################################
########################################################################################

function add-dot-GroupBox-set-ipaddr($xpos,$ypos){
try{
$dot = New-Object Windows.Forms.Label
$dot.Location = New-Object System.Drawing.Point $xpos,$ypos
$dot.Size =  New-Object System.Drawing.Size 5,10
$dot.Text = "."
$GroupBox_set_ipaddr.Controls.Add($dot)
}catch{Write-Log $_.Exception.Message -Severity 3}
}

function get-listnics{
try{
$DropDown_listnics.Items.Clear()
$list_nics = ((Get-WmiObject win32_networkadapter | select netconnectionid|Select-String -NotMatch "@{netconnectionid=}") -replace "@{netconnectionid=","") -replace "}",""
foreach($nics in $list_nics){$DropDown_listnics.Items.add($nics)}
}catch{Write-Log $_.Exception.Message -Severity 3}
}

function get-listmodifiednamenic{
try{
$DropDown_modifiednamenic.Items.Clear()
$list_modifiednamenic = @("$erog_name_nic",
"$erogbal_name_nic",
"$mgmt_name_nic",
"$mb_name_nic",
"$internal_name_nic")
foreach($modifiednamenic in $list_modifiednamenic){$DropDown_modifiednamenic.Items.add($modifiednamenic)}
}catch{Write-Log $_.Exception.Message -Severity 3}
}

function Rename-nic{
try{
if ($DropDown_modifiednamenic.Text -ne "" -and $DropDown_listnics.Text -ne ""){
    if ($DropDown_modifiednamenic.Text -match $DropDown_listnics.Text){
        Write-Log -Message "Nome nuovo NIC uguale a quello esistente" -Severity 3
        $wshell.Popup("Nome nuovo NIC uguale a quello esistente",0,"Error")
    }
    else{
        Get-NetAdapter -Name $DropDown_listnics.Text|Rename-NetAdapter -NewName $DropDown_modifiednamenic.Text -PassThru
        $old_namenic = $DropDown_listnics.Text
        $new_namenic = $DropDown_modifiednamenic.Text
        Write-Log -Message "Modifica NIC da $old_namenic a $new_namenic Effettuata"
    }
}
else{
Write-Log -Message "Uno o più campi per la rinomina NIC VUOTI" -Severity 3
$wshell.Popup("Uno o più campi per la rinomina NIC VUOTI",0,"Error")
}
}catch{Write-Log $_.Exception.Message -Severity 3}
}

function get-listnetmask{
try{
$list_netmasks = @("255.255.255.252/30","255.255.255.248/29","255.255.255.240/28","255.255.255.224/27",
"255.255.255.192/26","255.255.255.128/25","255.255.255.0/24","255.255.254.0/23","255.255.252.0/22","255.255.248.0/21",
"255.255.240.0/20","255.255.224.0/19","255.255.192.0/18","255.255.128.0/17","255.255.0.0/16","255.254.0.0/15",
"255.252.0.0/14","255.248.0.0/13","255.240.0.0/12","255.224.0.0/11","255.192.0.0/10","255.128.0.0/9",
"255.0.0.0/8","254.0.0.0/7","252.0.0.0/6","248.0.0.0/5","240.0.0.0/4","224.0.0.0/3","192.0.0.0/2","128.0.0.0/1")
foreach($networkmask in $list_netmasks){$DropDown_netmask.Items.add($networkmask)}
}catch{Write-Log $_.Exception.Message -Severity 3}
}

function set-networknic ($typeconf) {try{
$selected_nic = $DropDown_listnics.Text
if ($selected_nic -ne $null){
    Set-NetIPInterface -DHCP Disabled -InterfaceAlias $selected_nic -ErrorAction SilentlyContinue
    $gateway = (Out-String -InputObject ((((Get-NetRoute -InterfaceAlias $selected_nic|select NextHop|Select-String -NotMatch 0.0.0.0) -replace "@{NextHop=","") -replace "}","") -replace "::","")) -replace [Environment]::NewLine,""
    $static_ip_set = ((Get-NetIPAddress -InterfaceAlias $selected_nic -ErrorAction SilentlyContinue).IPAddress) -replace "169.254.*",$null
    if ($static_ip_set -NE $null){Remove-NetIPAddress -InterfaceAlias $selected_nic -Confirm:$false -ErrorAction SilentlyContinue}
    switch ($typeconf){
    "dhcp"{
        if ($gateway -ne "" ){Remove-NetRoute -InterfaceAlias $selected_nic -NextHop $gateway -Confirm:$false}
        Set-NetIPInterface -DHCP Enabled -InterfaceAlias $selected_nic
        Write-Log -Message "NIC $selected_nic` configurata in DHCP"
        $wshell.Popup("NIC "+$selected_nic+" configurata in DHCP",0,"Notice")
    }
    "static"{
        $set_ipaddr = $TextBox_ipaddr1.Text+"."+$TextBox_ipaddr2.Text+"."+$TextBox_ipaddr3.Text+"."+$TextBox_ipaddr4.Text
        $set_gateway = $TextBox_gw1.Text+"."+$TextBox_gw2.Text+"."+$TextBox_gw3.Text+"."+$TextBox_gw4.Text
        $MaskBits = $DropDown_netmask.Text.Split('/')[1]
        if ($gateway -NE "" ){Remove-NetRoute -InterfaceAlias $selected_nic -NextHop $gateway -Confirm:$false}
        if ($set_ipaddr -ne "10..." -or $DropDown_netmask -ne $null){
            if ($set_gateway -EQ "10..."){
                New-NetIPAddress -InterfaceAlias $selected_nic -AddressFamily "IPv4" -IPAddress $set_ipaddr -PrefixLength $MaskBits
            }
            else{
                New-NetIPAddress -InterfaceAlias $selected_nic -AddressFamily "IPv4" -IPAddress $set_ipaddr -PrefixLength $MaskBits -DefaultGateway $set_gateway
            }
            Write-Log -Message "NIC $selected_nic` configurata con IP statico"
            $wshell.Popup("NIC "+$selected_nic+" configurata con IP statico",0,"Notice")
        }        
        else {
            Write-Log -Message "Uno o più campi per settaggio IP NIC VUOTI" -Severity 3
            $wshell.Popup("Uno o più campi per settaggio IP NIC VUOTI",0,"Error")
        }
    }}
}
else {
    Write-Log -Message "NIC non selezionata da lista nomi NIC correnti" -Severity 3
    $wshell.Popup("NIC non selezionata da lista nomi NIC correnti",0,"Error")
}
}catch{Write-Log $_.Exception.Message -Severity 3}
}

function Binding-nic{
try{
$wshell.Popup('Per poter cambiare l`ordine del Binding
cliccare il tasto "Alt" -> "Advanced" -> "Advanced Settings..."',0,"Warning")
Write-Log -Message "Apertura modifica ordine Binding"
ncpa.cpl
}catch{Write-Log $_.Exception.Message -Severity 3}
}

function configure-dns($envi){
try{
if ($DropDown_listnics.Text -ne ""){
switch ($envi){
    1 {$Domain = "NORD"
    netsh interface ip set dns $DropDown_listnics.Text static 10.208.77.86 primary
    netsh interface ip add dns $DropDown_listnics.Text 10.208.77.84
    netsh interface ip add dns $DropDown_listnics.Text 10.207.72.244
    netsh interface ip set wins $DropDown_listnics.Text static 10.208.77.84
    netsh interface ip add wins $DropDown_listnics.Text 10.207.72.244 index=2
    netsh interface ip show config $DropDown_listnics.Text}
    2 {$Domain = "CENTRO"
    netsh interface ip set dns $DropDown_listnics.Text static 10.207.72.245 primary
    netsh interface ip add dns $DropDown_listnics.Text 10.207.72.244
    netsh interface ip add dns $DropDown_listnics.Text 10.208.77.84
    netsh interface ip set wins $DropDown_listnics.Text static 10.207.72.244
    netsh interface ip add wins $DropDown_listnics.Text 10.208.77.84 index=2
    netsh interface ip show config $DropDown_listnics.Text}
    3 {$Domain = "SUD"
    netsh interface ip set dns $DropDown_listnics.Text static 10.205.73.85 primary
    netsh interface ip add dns $DropDown_listnics.Text 10.205.73.84
    netsh interface ip add dns $DropDown_listnics.Text 10.207.72.244
    netsh interface ip set wins $DropDown_listnics.Text static 10.205.73.84
    netsh interface ip add wins $DropDown_listnics.Text 10.207.72.244 index=2
    netsh interface ip show config $DropDown_listnics.Text}
    4 {$Domain = "CERT"
    netsh interface ip set dns $DropDown_listnics.Text static 10.203.123.84 primary
    netsh interface ip add dns $DropDown_listnics.Text 10.203.123.85
    netsh interface ip set wins $DropDown_listnics.Text static 10.203.123.85
    netsh interface ip add wins $DropDown_listnics.Text 10.203.123.84 index=2
    netsh interface ip show config $DropDown_listnics.Text}
    5 {$Domain = "SVILL"
    netsh interface ip set dns $DropDown_listnics.Text static 10.10.3.11 primary
    netsh interface ip add dns $DropDown_listnics.Text 10.10.2.14
    netsh interface ip add dns $DropDown_listnics.Text 10.10.1.18
    netsh interface ip set wins $DropDown_listnics.Text static 10.10.3.11
    netsh interface ip add wins $DropDown_listnics.Text 10.10.2.14 index=2
    netsh interface ip add wins $DropDown_listnics.Text 10.10.1.18 index=3
    netsh interface ip show config $DropDown_listnics.Text}
    6 {$Domain = "MANAGEMENT"
    netsh interface ip set dns $DropDown_listnics.Text static 10.199.0.201 primary
    netsh interface ip add dns $DropDown_listnics.Text 10.199.0.200
    netsh interface ip show config %HN%_MB}
}
Write-Log -Message "Settaggio DNS $domain Effettuato"}
else {
    Write-Log -Message "NIC non selezionata da lista nomi NIC correnti" -Severity 3
    $wshell.Popup("NIC non selezionata da lista nomi NIC correnti",0,"Error")}
}catch{Write-Log $_.Exception.Message -Severity 3}
}

function reset-nonpresent-nic{
try{
netsh int ip reset reset.log
set devmgr_show_nonpresent_devices=1
Write-Log -Message "Apertura pulizia nonpresent-nic"
start devmgmt.msc
}catch{Write-Log $_.Exception.Message -Severity 3}
}

########################################################################################
###############################functions TabPageServices################################
########################################################################################

function firewall-disable{
try{
#netsh advfirewall set allprofiles state off
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
Write-Log -Message "Firewall Disabilitato"
}catch{Write-Log $_.Exception.Message -Severity 3}
}

function rdp-enable{
try{
set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server'-name "fDenyTSConnections" -Value 0
Write-Log -Message "Remote Desktop Abilitato"
}catch{Write-Log $_.Exception.Message -Severity 3}
}

#function snmp-service-install{
#try{
#Add-WindowsFeature SNMP-Service -IncludeManagementTools -IncludeAllSubFeature
#Write-Log -Message "SNMP Service Installato"
#}catch{Write-Log $_.Exception.Message -Severity 3}
#}
#
#function snmp-service-configure{
#try{
#REG Delete HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SNMP\Parameters\ValidCommunities /va /f
#REG Add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SNMP\Parameters\ValidCommunities /v public /t REG_DWORD /d 4 /f
#REG Add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SNMP\Parameters\TrapConfiguration\public /f
#REG Delete HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SNMP\Parameters\PermittedManagers /va /f
#Write-Log -Message "SNMP Service Configurato"
#}catch{Write-Log $_.Exception.Message -Severity 3}
#}

#function snmp-service-remove{
#try{
#Remove-WindowsFeature SNMP-Service,SNMP-WMI-Provider -IncludeManagementTools -Remove
#Write-Log -Message "SNMP Service rimosso"
#$wshell.Popup("Per completare la rimozione riavviare il server",0,"Warning")
#}catch{Write-Log $_.Exception.Message -Severity 3}
#}

#function activate-routing{
#try{
#$DropDown_listnics.Items.Clear()
#$list_nics = ((Get-WmiObject win32_networkadapter | select netconnectionid|Select-String -NotMatch "@{netconnectionid=}") -replace "@{netconnectionid=","") -replace "}",""
#foreach($nics in $list_nics){
#netsh interface ipv4 set interface "$nics" weakhostsend=enabled
#Write-Log -Message "Routing attivato sulla NIC $nics"}
#}catch{Write-Log $_.Exception.Message -Severity 3}
#}

#function install-dotnet35{
#try{
#switch ((Get-WindowsFeature -Name NET-Framework-Core).installstate){
#    Removed{
#        $source_path = (Get-WmiObject Win32_CDROMDrive).Drive
#        $source_path = "$source_path\sources\sxs"
#        if (Test-Path $source_path){
#            Install-WindowsFeature NET-Framework-Core -Source $source_path
#            Write-Log -Message ".NET framework 3.5 installato correttamente"
#            }
#        else{
#            Write-Log -Message ".NET framework 3.5 non installato causa DVD Windows non montato" -Severity 3
#            }
#        }
#    Available{
#        Install-WindowsFeature NET-Framework-Core
#        Write-Log -Message ".NET framework 3.5 installato correttamente"
#        }
#    Installed{
#        Write-Log -Message ".NET framework 3.5 già  installato" -Severity 2
#        }
#    }
#}catch{Write-Log $_.Exception.Message -Severity 3}
#}

#function install-iis{
#try{
#install-dotnet35
#invoke-expression 'cmd /c start powershell -OutputFormat Text -Command {Install-WindowsFeature Web-Http-Redirect,Web-Net-Ext45,Web-Asp-Net45,Web-Net-Ext,Web-Asp-Net,Web-ISAPI-Ext,Web-ISAPI-Filter,Web-Request-Monitor,Web-Http-Tracing,Web-Basic-Auth,Web-CertProvider,Web-Client-Auth,Web-Digest-Auth,Web-Cert-Auth,Web-IP-Security,Web-Url-Auth,Web-Windows-Auth,Web-Static-Content -IncludeManagementTools;pause}'
#$wshell.Popup("Installazione IIS completata",0,"Warning")
#Write-Log -Message "Installazione IIS completata"
#}catch{Write-Log $_.Exception.Message -Severity 3}
#}
#
#function install-failover{
#try{
#invoke-expression 'cmd /c start powershell -OutputFormat Text -Command {Install-WindowsFeature Failover-Clustering -IncludeManagementTools -IncludeAllSubFeature;pause}'
#$wshell.Popup("Installazione Failover-clustering completata",0,"Warning")
#Write-Log -Message "Installazione Failover-clustering completata"
#}catch{Write-Log $_.Exception.Message -Severity 3}
#}

#function remove-agent-SCCM(){
#try{
#if (Test-Path $env:windir\SysWOW64\CCM\ccmsetup.exe){
#$intAnswer = $wshell.Popup("Sei sicuro di voler disinstallare l`'agent SCCM?",0,"Warning",4)
#If ($intAnswer -eq 6){
#    &$env:windir\ccmsetup\ccmsetup.exe /uninstall
#    RD /S /Q $env:windir\ccmsetup
#    del /F $env:windir\SMSCFG.INI
#    $Label_Report_SCCM.Text = "SCCM: Not Installed"
#    $Label_Report_SCCM.ForeColor = "Red"
#    $Label_Report_SCCM.Enabled = $true
#    Write-Log -Message "Agent SCCM disinstallato"
#    $wshell.Popup("Agent SCCM disinstallato",3,"Warning")
#    }
#else{
#    $wshell.Popup("Operazione Annullata",3,"Warning")
#    }
#}
#else{
#    $Label_Report_SCCM.Text = "SCCM: Not Installed"
#    $Label_Report_SCCM.ForeColor = "Red"
#    $Label_Report_SCCM.Enabled = $true
#    Write-Log -Message "Agent SCCM non presente" -Severity 3
#    $wshell.Popup("Agent SCCM non presente",3,"Error")
#}
#}catch{Write-Log $_.Exception.Message -Severity 3}
#}

#####function for event forwarding subscription manager#####

function evf-to1(){
try{
$PSScriptRoot 
$ScriptToRun= $PSScriptRoot+"\bin\Configure_WinRM.ps1"
&$ScriptToRun
		REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\EventLog\EventForwarding\SubscriptionManager"          /v 1 /t REG_SZ /d Server=https://PLMSWTC03V.RETE.POSTE:5986/wsman/SubscriptionManager/WEC   /f
		cmd /c C:\Temp\bin\LGPO\lgpo.exe /g c:\temp\bin\LGPO\gpo_to1
#LGPO.exe /g c:\temp\LGPO\GPO
Write-Log "Event forwarding applicato per TORINO/AZURE 1"
}catch{Write-Log $_.Exception.Message -Severity 3}
}

function evf-to2(){
try{
$PSScriptRoot 
$ScriptToRun= $PSScriptRoot+"\bin\Configure_WinRM.ps1"
&$ScriptToRun
		REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\EventLog\EventForwarding\SubscriptionManager"          /v 1 /t REG_SZ /d Server=https://PLMSWTC04V.RETE.POSTE:5986/wsman/SubscriptionManager/WEC   /f
cmd /c c:\temp\bin\LGPO\lgpo.exe /g c:\temp\bin\LGPO\gpo_to2
#LGPO.exe /g c:\temp\LGPO\GPO
Write-Log "Event forwarding applicato per TORINO/AZURE 2"
}catch{Write-Log $_.Exception.Message -Severity 3}
}

function evf-po(){
try{
$PSScriptRoot 
$ScriptToRun= $PSScriptRoot+"\bin\Configure_WinRM.ps1"
&$ScriptToRun
		REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\EventLog\EventForwarding\SubscriptionManager"          /v 1 /t REG_SZ /d Server=https://PLMSWPC01V.RETE.POSTE:5986/wsman/SubscriptionManager/WEC   /f
		cmd /c c:\temp\bin\LGPO\lgpo.exe /g c:\temp\bin\LGPO\gpo_po
#LGPO.exe /g c:\temp\LGPO\GPO
Write-Log "Event forwarding applicato per POMEZIA"
}catch{Write-Log $_.Exception.Message -Severity 3}
}

function evf-ro(){
try{
$PSScriptRoot 
$ScriptToRun= $PSScriptRoot+"\bin\Configure_WinRM.ps1"
&$ScriptToRun
		REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\EventLog\EventForwarding\SubscriptionManager"          /v 1 /t REG_SZ /d Server=https://PLMSWRC01V.RETE.POSTE:5986/wsman/SubscriptionManager/WEC  /f
		cmd /c c:\temp\bin\LGPO\lgpo.exe /g c:\temp\bin\LGPO\gpo_ro
#LGPO.exe /g c:\temp\LGPO\GPO
Write-Log "Event forwarding applicato per ROZZANO"
}catch{Write-Log $_.Exception.Message -Severity 3}
}

function evf-co(){
try{
$PSScriptRoot 
$ScriptToRun= $PSScriptRoot+"\bin\Configure_WinRM.ps1"
&$ScriptToRun
		REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\EventLog\EventForwarding\SubscriptionManager"          /v 1 /t REG_SZ /d Server=https://PLMSWBC03V.RETE.POSTE:5986/wsman/SubscriptionManager/WEC   /f
		cmd /c c:\temp\bin\LGPO\lgpo.exe /g c:\temp\bin\LGPO\gpo_co1
#LGPO.exe /g c:\temp\LGPO\GPO
Write-Log "Event forwarding applicato per CONGRESSI/EUROPA 1"
}catch{Write-Log $_.Exception.Message -Severity 3}
}

####KMS####

function act-kms(){
try{

slmgr /skms pkms01v.rete.poste:1688
slmgr.vbs /ipk $TextBox_key.Text
slmgr.vbs /ato
Write-Log -Message "Licenza KMS installata"
}catch{Write-Log $_.Exception.Message -Severity 3}
}

function act-mak(){
try{
slmgr -ipk $TextBox_key.Text
$activation_code = (cscript.exe C:\Windows\System32\slmgr.vbs /dti| %{$_.Split(':')[1]})
$activation_code = $activation_code[3] -replace ' ',''
$activation_code = ([regex]::matches($activation_code, '.{1,7}') | %{$_.value}) -join ' '
$wshell.Popup("
  A               B              C             D            E            F             G            H            I
$activation_code",0,"Activation Code")
slui 4
Write-Log -Message "Licenza MAK installata"
}catch{Write-Log $_.Exception.Message -Severity 3}
}

########################################################################################
################################functions TabPageMcAfee#################################
########################################################################################

function agent-McAfee($envi){
try{
if (Test-Path $dir_McAfee){
$dir_McAfee_agent = ((dir $dir_McAfee|Select Name|Select-String Agent) -replace "@{Name=","") -replace "}",""
$dir_McAfee_agent = "$dir_McAfee\$dir_McAfee_agent"
switch ($envi){
        1 {
        $McAfee_agent_svil = ((dir "$dir_McAfee_agent\Sviluppo"|Select Name|Select-String FramePkg) -replace "@{Name=","") -replace "}",""
        $McAfee_agent_svil = "$dir_McAfee_agent\Sviluppo\$McAfee_agent_svil"
        Write-Log "Agent McAfee Sviluppo avviato"
        Start-Process "$McAfee_agent_svil" -Wait
        }
        2 {
        $McAfee_agent_cert = ((dir "$dir_McAfee_agent\Certificazione"|Select Name|Select-String FramePkg) -replace "@{Name=","") -replace "}",""
        $McAfee_agent_cert = "$dir_McAfee_agent\Certificazione\$McAfee_agent_cert"
        Write-Log "Agent McAfee Certificazione avviato"
        Start-Process "$McAfee_agent_cert" -Wait
        }
        3 {
        $McAfee_agent_prod = ((dir "$dir_McAfee_agent\Produzione"|Select Name|Select-String FramePkg) -replace "@{Name=","") -replace "}",""
        $McAfee_agent_prod = "$dir_McAfee_agent\Produzione\$McAfee_agent_prod"
        Write-Log "Agent McAfee Produzione avviato"
        Start-Process "$McAfee_agent_prod" -Wait
        }
        default {""}
        }
if (Test-Path "C:\Program Files (x86)\McAfee\Common Framework\cmdagent.exe"){
    & "C:\Program Files (x86)\McAfee\Common Framework\cmdagent.exe" /s
    Write-Log -Message "Installazione agent McAfee completata"}
else{
    if(Test-Path "C:\Program Files\McAfee\Agent\cmdagent.exe"){
        & "C:\Program Files\McAfee\Agent\cmdagent.exe" /s
        Write-Log -Message "Installazione agent McAfee completata"}
    else{Write-Log -Message "cmdagent.exe non trovato" -Severity 3}}
}
else{Write-Log -Message "Directory $dir_McAfee non presente" -Severity 3}
}catch{Write-Log $_.Exception.Message -Severity 3}
}

function engine-McAfee{
try{
if (Test-Path $dir_McAfee){
$dir_McAfee_vse = ((dir $dir_McAfee|Select Name|Select-String VSE) -replace "@{Name=","") -replace "}",""
$dir_McAfee_vse = "$dir_McAfee\$dir_McAfee_vse"
$mcafee = "C:\Temp\McAfee\McAfee_vse\setupEP.exe"
$arguments = 'ADDLOCAL="TP,ATP" /quiet'
start-process $mcafee $arguments -Wait
Write-log -Message "Installazione ENS McAfee completata"
}
else{Write-Log -Message "Directory $dir_McAfee non presente" -Severity 3}
}catch{Write-Log $_.Exception.Message -Severity 3}
}

########################################################################################
################################functions TabPageAgentHP################################
########################################################################################
<#
function get-listip{try{
if($TabPageAgentHP.Enabled){
$DropDown_listip.Items.Clear()
$list_ip = ((Get-NetIPAddress|Select IPAddress|Select-String -Pattern ::, 169.254., 127.0.0.1 -NotMatch) -replace "@{IPAddress=","") -replace "}",""
foreach($ips in $list_ip){$DropDown_listip.Items.add($ips)}}
}catch{Write-Log $_.Exception.Message -Severity 3}
}

function configure-hostsfile{try{
$hosts_file = "$env:windir\system32\drivers\etc\hosts"
$selected_ip = $DropDown_listip.text
if ($selected_ip -ne ""){
    $file_hosts_modified = (cat $hosts_file|Select-String -pattern $env:COMPUTERNAME, POMUS00V, COMUS00V, Manager -notmatch|Select-String "\w"|ForEach-Object { $_.line})
    echo $file_hosts_modified > $hosts_file
    ac -Path $hosts_file -Value "`n# Manager OV/O"
    ac -Path $hosts_file -Value "10.179.107.143`tPOMUS00V.rete.poste`tPOMUS00V"
	ac -Path $hosts_file -Value "10.194.192.6`tPOMIDC.rete.poste`tPOMIDC"
	ac -Path $hosts_file -Value "10.179.107.142`tPPMMG01V.rete.poste`tPPMMG01V"
    # Server di Certificazione
    ac -Path $hosts_file -Value "10.179.247.236`tCOMUS00V.retecert.postecert`tCOMUS00V"
	ac -Path $hosts_file -Value "10.179.240.3`tCOMIDC.retecert.postecert`tCOMIDC"
    ac -Path $hosts_file -Value "10.179.247.214`tCPMMG01V.retecert.postecert`tCPMMG01V"
    ac -Path $hosts_file -Value "$selected_ip`t$env:COMPUTERNAME"
    Write-Log -Message "file hosts Configurato"
    $wshell.Popup("File hosts configurato",0,"Warning")}
else{$wshell.Popup("Seleziona un IP dalla lista sotto il bottone",0,"Error")}
}catch{Write-Log $_.Exception.Message -Severity 3}}

Function Install-AgentHP{
try{
if (Test-Path $oainstallFile){
	$wshell.Popup("Setup presente`nprocedo con l'installazione",3,"Warning")
    Start-Process "cmd.exe" "/K cd C:\Temp\Agent_HP\INSTDIR\ & cscript oainstall.vbs -i -a & pause & exit" -Wait
	$wshell.Popup("Installazione Agent HP completata",0,"Warning")
    Write-Log -Message "Installazione Agent HP completata"
    }
else{
    $wshell.Popup("Setup Agent HP NON Presente`nCopialo sotto la cartella C:\Temp\Agent_HP\INSTDIR",0,"Warning")
    Write-Log -Message "Setup Agent HP NON Presente, Copialo sotto la cartella C:\Temp\Agent_HP\INSTDIR" -Severity 2
    }
}catch{Write-Log $_.Exception.Message -Severity 3}
}

function refresh-progressbar-AHP-config($progress){
$progressBar_agenthp_configure.Value = $progress
$Label_agenthp_configure_progressbar.Text = "Stato Configurazione: $progress%"
}

Function Configure-AgentHP{try{
$selected_ip = $DropDown_listip.text
if ($selected_ip -ne ""){
    $progressBar_agenthp_configure.Enabled = $true
    $Label_agenthp_configure_progressbar.Enabled = $true
    refresh-progressbar-AHP-config 2
    if (Test-Path 'C:\Program Files\HP\HP BTO Software\bin\win64\ovconfget.exe'){
        $Test_exist_conf=((& 'C:\Program Files\HP\HP BTO Software\bin\win64\ovconfget.exe' bbc.http|select-string CLIENT_BIND_ADDR) -replace 'CLIENT_BIND_ADDR=','')
        refresh-progressbar-AHP-config 5
        if ($Test_exist_conf -ne $null){
            refresh-progressbar-AHP-config 70
         	$wshell.Popup("File di configurazione già  configurato",3,"WARNING")
            Write-Log -Message "File di configurazione già  configurato" -Severity 2
        }
        else{
            refresh-progressbar-AHP-config 10
        	$wshell.Popup("File NON Configurato`nProcedo con la configurazione",3,"Warning")
            refresh-progressbar-AHP-config 15
    	    & 'C:\Program Files\HP\HP BTO Software\bin\win64\ovconfchg.exe' -ns bbc.http -set CLIENT_BIND_ADDR $DropDown_listip.Text
			refresh-progressbar-AHP-config 20
    	    & 'C:\Program Files\HP\HP BTO Software\bin\win64\ovconfchg.exe' -ns coda.comm -set CLIENT_BIND_ADDR $DropDown_listip.Text
			refresh-progressbar-AHP-config 25
    	    & 'C:\Program Files\HP\HP BTO Software\bin\win64\ovconfchg.exe' -ns eaagt -set OPC_IP_ADDRESS $DropDown_listip.Text
            refresh-progressbar-AHP-config 35
            & 'C:\Program Files\HP\HP BTO Software\bin\win64\ovconfchg.exe' -ns coda.comm -set SERVER_BIND_ADDR localhost
            refresh-progressbar-AHP-config 45
            & 'C:\Program Files\HP\HP BTO Software\bin\win64\ovconfchg.exe' -ns coda -set SSL_SECURITY NONE
			refresh-progressbar-AHP-config 55
            $Domain = (gwmi WIN32_ComputerSystem).Domain
            switch ($Domain){ retecert.postecert 
            {
            & 'C:\Program Files\HP\HP BTO Software\bin\win64\ovconfchg.exe' -ns sec.core.auth -set MANAGER COMUS00V
			refresh-progressbar-AHP-config 65
            & 'C:\Program Files\HP\HP BTO Software\bin\win64\ovconfchg.exe' -ns sec.core.auth -set MANAGER_ID 2262421a-a66d-758c-001f-b7f8738d8cba
            refresh-progressbar-AHP-config 70
            & cscript 'C:\Program Files\HP\HP BTO Software\bin\win64\OpC\install\opcactivate.vbs' -srv comus00v -cert_srv comus00v
            }
            rete.poste 
            {
            & 'C:\Program Files\HP\HP BTO Software\bin\win64\ovconfchg.exe' -ns sec.core.auth -set MANAGER POMUS00V
			refresh-progressbar-AHP-config 65
            & 'C:\Program Files\HP\HP BTO Software\bin\win64\ovconfchg.exe' -ns sec.core.auth -set MANAGER_ID 2262421a-a66d-758c-001f-b7f8738d8cba
            refresh-progressbar-AHP-config 70
            & cscript 'C:\Program Files\HP\HP BTO Software\bin\win64\OpC\install\opcactivate.vbs' -srv pomus00v -cert_srv pomus00v
            }
            }
			refresh-progressbar-AHP-config 75
			& "C:\Program Files\HP\HP BTO Software\bin\win64\ovcert.exe" -certreq
            refresh-progressbar-AHP-config 85
            refresh-progressbar-AHP-config 90
            refresh-progressbar-AHP-config 95
            refresh-progressbar-AHP-config 100
            $wshell.Popup("Fine della configurazione Agent HP",0,"Warning")
            Write-Log -Message "Fine della configurazione Agent HP"
            }
    }
    else{
    $wshell.Popup("Agent HP non installato",0,"Error")
    Write-Log -Message "Agent HP non installato" -Severity 3
    }
}
else{
    $wshell.Popup("Seleziona un IP dalla lista sotto il bottone",0,"Error")
    Write-Log -Message "Seleziona un IP dalla lista sotto il bottone" -Severity 3
    }
}catch{Write-Log $_.Exception.Message -Severity 3}
refresh-progressbar-AHP-config 100
}


function verify-agenthp(){
$RichTextBox_agenthp_verify.text = (& "C:\Program Files\HP\HP BTO Software\bin\win64\ovconfget.exe" bbc.http|Out-String)
$RichTextBox_agenthp_verify.AppendText((& "C:\Program Files\HP\HP BTO Software\bin\win64\ovconfget.exe" bbc.cb|Out-String))
$RichTextBox_agenthp_verify.AppendText((& "C:\Program Files\HP\HP BTO Software\bin\win64\ovcert.exe" -status|Out-String))
}
#>
########################################################################################
################################functions TabPageAgentZabbix################################
########################################################################################

Function Install-Zabbix_prod
{
	try
	{
		if (Test-Path $Zabbixprod_path)
		{
			$wshell.Popup("Setup presente`nprocedo con l'installazione", 3, "Warning")
			Start-Process -Filepath "C:\Temp\Zabbix\Prod\ZabbAgent5_inst.bat" -Wait
			$wshell.Popup("Installazione Zabbix Produzione completata", 0, "Warning")
			Write-Log -Message "Installazione Zabbix Produzione completata"
		}
		else
		{
			$wshell.Popup("Setup Zabbix NON Presente`nCopialo sotto la cartella C:\Temp\Zabbix\", 0, "Warning")
			Write-Log -Message "Setup Zabbix NON Presente, Copialo sotto la cartella  C:\Temp\Zabbix\" -Severity 2
		}
	}
	catch { Write-Log $_.Exception.Message -Severity 3 }
}

Function Install-Zabbix_cert
{
	try
	{
		if (Test-Path $Zabbixcert_path)
		{
			$wshell.Popup("Setup presente`nprocedo con l'installazione", 3, "Warning")
			Start-Process -Filepath "C:\temp\Zabbix\Cert\ZabbAgent5_inst.bat" -Wait
			$wshell.Popup("Installazione Zabbix Certificazione completata", 0, "Warning")
			Write-Log -Message "Installazione Zabbix Certificazione completata"
		}
		else
		{
			$wshell.Popup("Setup Zabbix NON Presente`nCopialo sotto la cartella C:\Temp\Zabbix\", 0, "Warning")
			Write-Log -Message "Setup Zabbix NON Presente, Copialo sotto la cartella  C:\Temp\Zabbix\" -Severity 2
		}
	}
	catch { Write-Log $_.Exception.Message -Severity 3 }
}


########################################################################################
################################functions TabPageAgentDD################################
########################################################################################

function get-EnvTAG{
try{
$DropDown_EnvTAG.Items.Clear()
$list_EnvTAG = @('svil',
'coll','cert','prod')
foreach($EnvTAG in $list_EnvTAG){$DropDown_EnvTAG.Items.add($EnvTAG)}
}catch{Write-Log $_.Exception.Message -Severity 3}
}

function get-SiteTAG{
try{
$DropDown_SiteTAG.Items.Clear()
$list_SiteTAG = @('dcrm1',
'dcrmb','dcto')
foreach($SiteTAG in $list_SiteTAG){$DropDown_SiteTAG.Items.add($SiteTAG)}
}catch{Write-Log $_.Exception.Message -Severity 3}
}

function get-TypeTAG{
try{
$DropDown_TypeTAG.Items.Clear()
$list_TypeTAG = @('fisico',
'virtuale')
foreach($TypeTAG in $list_TypeTAG){$DropDown_TypeTAG.Items.add($TypeTAG)}
}catch{Write-Log $_.Exception.Message -Severity 3}
}

function get-AvailabilityTAG{
try{
$DropDown_AvailabilityTAG.Items.Clear()
$list_AvailabilityTAG = @('campus',
'torino')
foreach($AvailabilityTAG in $list_AvailabilityTAG){$DropDown_AvailabilityTAG.Items.add($AvailabilityTAG)}
}catch{Write-Log $_.Exception.Message -Severity 3}
}

function get-RoleTAG{
try{
$DropDown_RoleTAG.Items.Clear()
$list_RoleTAG = @('DB',
'AS','WS')
foreach($RoleTAG in $list_RoleTAG){$DropDown_RoleTAG.Items.add($RoleTAG)}
}catch{Write-Log $_.Exception.Message -Severity 3}
}

function remove-DD{
try{
& "C:\Program Files\Datadog\Datadog Agent\bin\agent.exe" stopservice
Get-WmiObject -Class Win32_Product | Select-Object -Property Name
$MyApp = Get-WmiObject -Class Win32_Product | Where-Object{$_.Name -eq "Datadog Agent"}
$MyApp.Uninstall()
Write-Log "DD Rimosso"
}catch{Write-Log $_.Exception.Message -Severity 3}
}

function restart-agentDD(){
try{
Restart-Service -DisplayName "Datadog Agent" -Force
#& “C:\Program Files\Datadog\Datadog Agent\bin\agent.exe" run
#$wshell.Popup("Proxy Certificazione configurato",0,"Warning")
Write-Log "Agent DataDog Riavviato"
}catch{Write-Log $_.Exception.Message -Severity 3}
}

function startgui(){
try{

& "C:\Program Files\Datadog\Datadog Agent\bin\agent.exe" launch-gui
#$wshell.Popup("Proxy Certificazione configurato",0,"Warning")
Write-Log "Avvio Agent DataDog GUI"
}catch{Write-Log $_.Exception.Message -Severity 3}
}

######CONFIGURAZIONE PROXY PER DATA DOG AGENT########  
function configure-proxyprod(){
try{
$PSScriptRoot 
$ScriptToRun= $PSScriptRoot+"\proxyprod.ps1"
&$ScriptToRun
$wshell.Popup("Proxy Produzione configurato",0,"Warning")
Write-Log "Proxy Produzione configurato"
}catch{Write-Log $_.Exception.Message -Severity 3}
}

function configure-proxycert(){
try{
$PSScriptRoot 
$ScriptToRun= $PSScriptRoot+"\proxycert.ps1"
&$ScriptToRun
$wshell.Popup("Proxy Certificazione configurato",0,"Warning")
Write-Log "Proxy Certificazione configurato"
}catch{Write-Log $_.Exception.Message -Severity 3}
}

function checkproxycert ($hostname= 'http://proxytmg.gss.rete',$port=8080,$timeout=100) {
try{
  $requestCallback = $state = $null
  $client = New-Object System.Net.Sockets.TcpClient
  $beginConnect = $client.BeginConnect($hostname,$port,$requestCallback,$state)
  Start-Sleep -milli $timeOut
  if ($client.Connected) { $wshell.Popup("Test proxy Certificazione RIUSCITO!",0,"Warning")
  Write-Log -Message "Proxy certificazione ok" -Severity 2}
  else { $wshell.Popup("Test proxy Certificazione FALLITO!",0,"Warning")
  Write-Log -Message "Invalid proxy server address or port:  $($hostname):$($port)" -Severity 2
  }
  }catch{Write-Log $_.Exception.Message -Severity 3}
  #[pscustomobject]@{hostname=$hostname;port=$port;open=$open}
}

function checkproxyprod ($hostname= 'http://proxytmg.gss.rete',$port=8080,$timeout=100) {
try{
  $requestCallback = $state = $null
  $client = New-Object System.Net.Sockets.TcpClient
  $beginConnect = $client.BeginConnect($hostname,$port,$requestCallback,$state)
  Start-Sleep -milli $timeOut
  if ($client.Connected) { $wshell.Popup("Test proxy Produzione RIUSCITO!",0,"Warning")
  Write-Log -Message "Proxy Produzione ok" -Severity 2}
  else { $wshell.Popup("Test proxy Produzione FALLITO!",0,"Warning")
  Write-Log -Message "Invalid proxy server address or port:  $($hostname):$($port)" -Severity 2
  }
  }catch{Write-Log $_.Exception.Message -Severity 3}
  #[pscustomobject]@{hostname=$hostname;port=$port;open=$open}
}

#Downloading and Install Agent DataDog"

Function Install-AgentDD{
#try{
Write-Host "Inizialing!"
#
Write-Host "Downloading DD-agent installation package."
$image_url = "https://s3.amazonaws.com/ddagent-windows-stable/datadog-agent-7-latest.amd64.msi"
$destin = "c:\temp\datadog-agent-7-latest.amd64.msi"
(New-Object System.Net.WebClient).DownloadFile($image_url, $destin)
#
### find time for installation schedule, one minute from now
##$nowp = (Get-Date).AddMinutes(1)
##$runat = Get-Date -date $nowp -format "HH:mm"
$wshell.Popup("Download Agent DataDog completato",0,"Warning")
Write-Log -Message "Download Agent DataDog completato"
####INSTALLING AGENT DATA DOG#########

$serv = $TextBox_service.text
$desc = $TextBox_service.text
$env = $DropDown_EnvTAG.Text
$site = $DropDown_SiteTAG.Text
$type = $DropDown_TypeTAG.Text
$role = $DropDown_RoleTAG.Text
$availability = $DropDown_AvailabilityTAG.Text
$DD_API_KEY = "57f07cb21edb0611f5c6a1a55eedd0cb"
$HOSTNAME = $env:COMPUTERNAME
#$TAGS = "service:$serv,env:$env,desc:$serv"

Write-Log -Message "Start Installation..." -Severity 2
	
	msiexec /i c:\temp\datadog-agent-7-latest.amd64.msi /l*v .\installation_log.txt /quiet APIKEY="$DD_API_KEY" HOSTNAME="$HOSTNAME" TAGS="env:$env,type:$type,region:italy,availability-zone:$availability,site:$site,org:pi,role:$role,cloud_provider:poste,service:$serv"

#msiexec /i c:\temp\datadog-agent-7-latest.amd64.msi /l*v .\installation_log.txt /quiet APIKEY="$DD_API_KEY" HOSTNAME="$HOSTNAME" TAGS="service='$serv',env='$env'"

# let install finish, takes only a couple seconds.
Start-Sleep -s 30

# stop agent for configuration
#stop-service datadogagent
& "C:\Program Files\Datadog\Datadog Agent\bin\agent.exe" stopservice
Write-Log -Message "Agent DD Stopped" -Severity 1
# optionally copy pre-configured integration configuration files to agent directories, like so:
Copy-Item -Path C:\ProgramData\Datadog\datadog.yaml -Destination C:\Temp\datadog.yaml
Write-Log -Message "export .yaml file to temp directory" -Severity 1
#start-service datadogagent
& "C:\Program Files\Datadog\Datadog Agent\bin\agent.exe" start-service
Write-Log -Message "Agent DD Started" -Severity 1
$wshell.Popup("Installazione Agent DataDog completata",0,"Warning")
Write-Log -Message "Agent DataDog installation completed" -Severity 1
##schtasks /create /RU "NT AUTHORITY\SYSTEM" /sc once /tn "Install_Datadog" /tr "Powershell.exe -File .\setup_2.ps1" /st ${runat} /RL HIGHEST 
}

########################################################################################
###############################functions TabPageReporting###############################
########################################################################################

function addto-checkcsv-text($name_type,$text){
if ($text -eq $null){$text = " "}
if ($name_type -ne $null){
    $wrapper = New-Object PSObject -Property @{$name_type = $text}
    ConvertTo-Csv -InputObject $wrapper -Delimiter ";" -NoTypeInformation|ac $File_R4C}
}

function addto-checkcsv-text-arow($name_check,$value_check){
if ($value_check -eq $null){$value_check = " "}
if ($name_check -ne $null){
'"'+$name_check+'";"'+$value_check+'"'|ac $File_R4C
}
}

function refresh-progressbar-R4C($progress){
$progressBar_R4C.Value = $progress
$Label_Report_summary.Text = "Stato: $progress%"
}

function Get-RegistryKeyContent($key,$value) {(Get-ItemProperty -Path $key $value -ErrorAction SilentlyContinue).$value}

function Run-Reporting{
Write-Log -Message "R4C avviato, generazione R4C in corso"
if (Test-Path $File_R4C){del $File_R4C}
$progressBar_R4C.Enabled = $true
$Label_Report_summary.Enabled = $true
addto-checkcsv-text-arow "Versione di WinPlementator" "$version_winplementator_full"
addto-checkcsv-text-arow "Script Checklist eseguito da" $env:USERNAME
$Label_Report_system.Enabled = $true
$Label_Report_system.ForeColor = "Orange"
$Label_Report_network.Enabled = $true
$Label_Report_network.ForeColor = "DarkRed"
$Label_Report_SCCM.Enabled = $true
$Label_Report_SCCM.ForeColor = "DarkRed"
$Label_Report_services.Enabled = $true
$Label_Report_services.ForeColor = "DarkRed"
$Label_Report_agenthp.Enabled = $true
$Label_Report_agenthp.ForeColor = "DarkRed"
$Label_Report_McAfee.Enabled = $true
$Label_Report_McAfee.ForeColor = "DarkRed"
$Label_Report_system.Text = "Sistema: In progress"
addto-checkcsv-text-arow "Data esecuzione" ((Get-Date).DateTime)
Add-Content $File_R4C `r
addto-checkcsv-text-arow "Hostname" $env:COMPUTERNAME
Add-Content $File_R4C `r
refresh-progressbar-R4C 3
addto-checkcsv-text-arow "CPU Modello" ((Get-WmiObject win32_processor).Name)
Add-Content $File_R4C `r
refresh-progressbar-R4C 4
addto-checkcsv-text-arow "CPU N core" ((Get-WmiObject win32_processor).NumberOfCores)
Add-Content $File_R4C `r
refresh-progressbar-R4C 5
addto-checkcsv-text-arow "RAM installata Gb" ((Get-WmiObject Win32_PhysicalMemory|Measure-Object -Property capacity -Sum).sum/1GB)
Add-Content $File_R4C `r
refresh-progressbar-R4C 10
addto-checkcsv-text-arow " " " "
Add-Content $File_R4C `r
addto-checkcsv-text-arow "Dimensione dischi Gb"
Add-Content $File_R4C `r
(Get-WmiObject win32_logicaldisk|Where-Object DriveType -eq 3|select DeviceID,@{Name="Size Disk";Expression={"{0:N0}" -f ($_.Size/1GB)}}|ConvertTo-Csv -Delimiter ";" -NoTypeInformation) -match "[0-9]"|ac $File_R4C
Add-Content $File_R4C `r
refresh-progressbar-R4C 13
addto-checkcsv-text-arow " " " "
Add-Content $File_R4C `r
addto-checkcsv-text-arow "6.7 SWAP Mb" ((Get-WmiObject Win32_PageFile).Filesize/1MB)
Add-Content $File_R4C `r
addto-checkcsv-text-arow " " " "
Add-Content $File_R4C `r
refresh-progressbar-R4C 17
addto-checkcsv-text-arow "1.3 versione SO" ((Get-WmiObject Win32_OperatingSystem).Caption)
Add-Content $File_R4C `r
refresh-progressbar-R4C 20
addto-checkcsv-text-arow "1.4 lingua SO" (Get-WinSystemLocale).Name
Add-Content $File_R4C `r
addto-checkcsv-text-arow "1.4 Fuso orario" ((((Get-WmiObject Win32_TimeZone).Caption).split("`(")[1]).split("`)")[0])
Add-Content $File_R4C `r
refresh-progressbar-R4C 22
addto-checkcsv-text-arow "1.4 Layout tastiera (deve essere 0409:00000410)" ((Get-WinUserLanguageList).InputMethodTips)
Add-Content $File_R4C `r
refresh-progressbar-R4C 25
addto-checkcsv-text " " "1.5 Attivazione licenza"
Get-WmiObject SoftwareLicensingProduct|where {$_.PartialProductKey}|select Name,LicenseStatus|ConvertTo-Csv -Delimiter ";" -NoTypeInformation|ac $File_R4C
Add-Content $File_R4C `r
refresh-progressbar-R4C 28
$Label_Report_network.Text = "Network: In progress"
$Label_Report_network.ForeColor = "Orange"
addto-checkcsv-text-arow " " " "
Add-Content $File_R4C `r
addto-checkcsv-text-arow "1.7 Ordine di binding NIC ed IP"
Add-Content $File_R4C `r
#(Get-NetAdapterBinding|where ComponentID -EQ 'ms_tcpip'|where Enabled -EQ True).Name|ac $File_R4C
$objReg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $env:COMPUTERNAME)
$objRegKey = $objReg.OpenSubKey("SYSTEM\\Currentcontrolset\\Services\\TCPIP\\Linkage" )
$arrItem = $objRegKey.GetValue("Bind")
foreach ($item in $arrItem) {
    $item = $item -replace "\\device\\", ""
    $objRegKey = $objReg.OpenSubKey("SYSTEM\\Currentcontrolset\\Control\Network\\{4D36E972-E325-11CE-BFC1-08002be10318}\\" + $item + "\\Connection")
    $strBind = $objRegKey.GetValue("Name")
    $objRegKeyIP = $objReg.OpenSubKey("SYSTEM\\Currentcontrolset\\Services\\TCPIP\\Parameters\\Interfaces\\" + $item )
    $arrItemIP = $objRegKeyIP.GetValue("IPAddress")
    foreach ($itemIP in $arrItemIP) {
    If ($itemIP -eq $null) {
            addto-checkcsv-text-arow $strBind "IP NOT ASSIGNED"
        }
        Else{
            addto-checkcsv-text-arow $strBind $itemIP
        }
    }
}
refresh-progressbar-R4C 31
Add-Content $File_R4C `r
addto-checkcsv-text " " "Associazione NIC - Modello"
Get-WmiObject win32_networkadapter|where netconnectionstatus -ne $null|select netconnectionid, name|ConvertTo-Csv -Delimiter ";" -NoTypeInformation|ac $File_R4C
Add-Content $File_R4C `r
refresh-progressbar-R4C 32
$Label_Report_SCCM.Text = "SCCM: In progress"
$Label_Report_SCCM.ForeColor = "Orange"
addto-checkcsv-text-arow " " " "
$sccm_check = (Get-Process|Where-Object ProcessName -EQ CcmExec).ProcessName
if ($sccm_check -EQ $null){
    addto-checkcsv-text-arow "1.8 Agent SCCM" "Non presente"
    $Label_Report_SCCM.Text = "SCCM: Not Installed"
    $Label_Report_SCCM.ForeColor = "Red"
}
else{
    addto-checkcsv-text-arow "Agent SCCM" "Attivo"
    refresh-progressbar-R4C 35
    addto-checkcsv-text-arow "Verifica KB necessarie SCCM" (Get-WmiObject Win32_QuickfixEngineering|select-string -inputobject {$_.HotfixID} -pattern  "KB2969339" ,"KB2919355")
    refresh-progressbar-R4C 38
    addto-checkcsv-text-arow "Verifica Numero KB installate" (Get-WmiObject Win32_QuickfixEngineering|Measure-Object HotFixID).Count
    $Label_Report_SCCM.Text = "SCCM: Finished"
    $Label_Report_SCCM.ForeColor = "DarkGreen"
}
refresh-progressbar-R4C 42
Add-Content $File_R4C `r 
# Dichiaro le variabili per Java
$outputJava = & cmd /c "java -version 2>&1"
addto-checkcsv-text-arow "1.8.1 Versione di Java installata" $outputJava
Add-Content $File_R4C `r
refresh-progressbar-R4C 43
addto-checkcsv-text-arow "1.9 Dominio di appartenenza" (Get-WmiObject Win32_ComputerSystem).domain
Add-Content $File_R4C `r
refresh-progressbar-R4C 45
$objOu = [ADSI]"WinNT://$env:Computername"
$localUsers = $objOu.Children|where Name -eq "Sfiadmsm"|select Path
if($localUsers -NE $Null){addto-checkcsv-text-arow "1.10 Verifca rename Administrator" "OK (Sfiadmsm)"}
else{
    $localUsers = $objOu.Children|where Name -eq "Administrator"|select Path
    if($localUsers -NE $Null){addto-checkcsv-text-arow "1.10 Verifca rename Administrator" "KO (Administrator)"}
    else{addto-checkcsv-text-arow "Verifca rename Administrator" "KO (Administrator/Sfiadmsm NON TROVATO)"}
}
Add-Content $File_R4C `r
refresh-progressbar-R4C 47
if((gwmi WIN32_ComputerSystem).Domain -NE "rete.testposte" -or (gwmi WIN32_ComputerSystem).Domain -NE "retecert.postecert"){
    $localUsers = $objOu.Children|where Name -eq "Sfiadmsm1"|select Path
    if($localUsers -NE $Null){addto-checkcsv-text-arow "1.10 Verifca presenza sfiadmsm1" "OK (Sfiadmsm1)"}
    else{addto-checkcsv-text-arow "1.10 Verifca presenza sfiadmsm1" "KO (Sfiadmsm1 NON TROVATO)"}
}
Add-Content $File_R4C `r
refresh-progressbar-R4C 50
$localUsers = $objOu.Children|where Name -eq "GSTSRPI"|select Path
if($localUsers -NE $Null){addto-checkcsv-text-arow "1.10 Verifca rename Guest" "OK (GSTSRPI)"}
else{
    $localUsers = $objOu.Children|where Name -eq "Guest"|select Path
    if($localUsers -NE $Null){addto-checkcsv-text-arow "1.10 Verifca rename Guest" "KO (Administrator)"}
    else{addto-checkcsv-text-arow "Verifca rename Guest" "KO (Guest/GSTSRPI NON TROVATO)"}
}
Add-Content $File_R4C `r
addto-checkcsv-text " " "Lista Home Directory esistenti"
(Get-Childitem "C:\Users").Name|ac $File_R4C
Add-Content $File_R4C `r
refresh-progressbar-R4C 55
$Label_Report_system.Text = "Sistema: Finished"
$Label_Report_system.ForeColor = "DarkGreen"
$Label_Report_services.Text = "Servizi: In progress"
$Label_Report_services.ForeColor = "Orange"
addto-checkcsv-text " " "Lista servizi sistema"
Get-WmiObject Win32_Service -Property Name,StartMode,State -Filter "Name='SNMP'"|select Name,State,StartMode|ConvertTo-Csv -Delimiter ";" -NoTypeInformation|ac $File_R4C
$sql_status = Get-WmiObject Win32_Service -Property Name,StartMode,State -Filter "Name='MSSQLSERVER'"|select Name,State,StartMode
if ($sql_status -NE $null){
addto-checkcsv-text " " "Stato installazione MSSQL"
$type = [Microsoft.Win32.RegistryHive]::LocalMachine
$regconnection = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($type, $env:COMPUTERNAME)
$instancekey = "SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL"
try {$openinstancekey = $regconnection.opensubkey($instancekey)}
catch {$out = $server + ",No SQL registry keys found"}
$instances = $openinstancekey.getvaluenames()
foreach ($instance in $instances) {
    $instancename = $openinstancekey.getvalue($instance)
    $instancesetupkey = "SOFTWARE\Microsoft\Microsoft SQL Server\" + $instancename + "\Setup"
    $openinstancesetupkey = $regconnection.opensubkey($instancesetupkey)
    $edition = $openinstancesetupkey.getvalue("Edition")
    $version = $openinstancesetupkey.getvalue("Version")
    switch -wildcard ($version) {
        "14.0*" {$nameversion = "SQL Server 2017";}
		"13.2*" {$nameversion = "SQL Server 2016 SP2";}
        "13.1*" {$nameversion = "SQL Server 2016 SP1";}
        "13.0*" {$nameversion = "SQL Server 2016";}
        "12.2*" {$nameversion = "SQL Server 2014 SP2";}
        "12.1*" {$nameversion = "SQL Server 2014 SP1";}
        "12.0*" {$nameversion = "SQL Server 2014";}
        "11.3*" {$nameversion = "SQL Server 2012 SP3";}
        "11.2*" {$nameversion = "SQL Server 2012 SP2";}
        "11.1*" {$nameversion = "SQL Server 2012 SP1";}
        "11.0*" {$nameversion = "SQL Server 2012";}
        "10.53*" {$nameversion = "SQL Server 2008 R2 SP3";}
        "10.52*" {$nameversion = "SQL Server 2008 R2 SP2";}
        "10.51*" {$nameversion = "SQL Server 2008 R2 SP1";}
        "10.50*" {$nameversion = "SQL Server 2008 R2";}
        "10.4*" {$nameversion = "SQL Server 2008 SP4";}
        "10.3*" {$nameversion = "SQL Server 2008 SP3";}
        "10.2*" {$nameversion = "SQL Server 2008 SP2";}
        "10.1*" {$nameversion = "SQL Server 2008 SP1";}
        "10.0*" {$nameversion = "SQL Server 2008";}
        default {$nameversion = $version;}
        }
    addto-checkcsv-text-arow "Versione MSSQL" "$nameversion $edition"
    }
addto-checkcsv-text-arow " " " "
Add-Content $File_R4C `r
###############################################################################################
# Cerca tutte le istanze presenti facendone l'elenco, per Certificazione è stata disabilitato
###############################################################################################
#$list_Servers_instance=([System.Data.Sql.SqlDataSourceEnumerator]::Instance.GetDataSources()|ConvertTo-Csv -NoTypeInformation|ConvertFrom-Csv)
#$ServerInstances=($list_Servers_instance).ServerName
#$username_sa="sa"
#$Password_sa="Passw0rd"
#($list_Servers_instance|select ServerName,InstanceName)|ConvertTo-Csv -Delimiter ";" -NoTypeInformation|ac $File_R4C
###############################################################################################
Add-Content $File_R4C `r
addto-checkcsv-text-arow " " " "
foreach ($ServerInstance in $ServerInstances) {
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") | Out-Null 
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.ConnectionInfo") | Out-Null  
$ServerConnection = New-Object "Microsoft.SqlServer.Management.Common.ServerConnection" $ServerInstance,$username_sa,$Password_sa
$Server = New-Object "Microsoft.SqlServer.Management.Smo.Server" $ServerConnection
try{$ServerConnection.Connect()
$VersionMajor = $Server.VersionMajor
switch($VersionMajor){
    14  {$Version = 14   ;$Number=140}
    13  {$Version = 13   ;$Number=130}
    12  {$Version = 12   ;$Number=120}
    11  {$Version = 11   ;$Number=110}
    10.5{$Version = 10_50;$Number=100}
    10  {$Version = 10   ;$Number=100}
}
$SSAS = Get-RegistryKeyContent "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\MSAS$Version.MSSQLSERVER\MSSQLServer\CurrentVersion" CurrentVersion
$SSRS = Get-RegistryKeyContent "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\MSRS$Version.MSSQLSERVER\MSSQLServer\CurrentVersion" CurrentVersion
$SSIS = Get-RegistryKeyContent "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$Number\DTS\Setup" Version
$SQLWriter = Get-RegistryKeyContent "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\SqlWriter\CurrentVersion" Version
$FullText = Get-RegistryKeyContent "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL$Version.MSSQLSERVER\Setup\SQL_FullText_Adv" Version
addto-checkcsv-text-arow "lista componenti installati del ServerName" $ServerInstance
if      ($SSIS -NE $null){addto-checkcsv-text-arow "SQL Server Integration Services" ""}
if  ($FullText -NE $null){addto-checkcsv-text-arow "SQL Server Full-Text Search" ""}
if      ($SSAS -NE $null){addto-checkcsv-text-arow "SQL Server Analysis Services" ""}
if      ($SSRS -NE $null){addto-checkcsv-text-arow "SQL Server Reporting Services" ""}
if ($SQLWriter -NE $null){addto-checkcsv-text-arow "SQLWriter" ""}
}catch{}
}
}
refresh-progressbar-R4C 60
Add-Content $File_R4C `r
addto-checkcsv-text " " "Stato installazione IIS"
try{
if ((Get-WindowsFeature -Name Web-Server).InstallState -EQ "Installed"){
Get-WindowsFeature -Name Web-Http-Redirect,Web-Net-Ext45,Web-Asp-Net45,Web-Net-Ext,Web-Asp-Net,Web-ISAPI-Ext,Web-ISAPI-Filter,Web-Request-Monitor,Web-Http-Tracing,Web-Basic-Auth,Web-CertProvider,Web-Client-Auth,Web-Digest-Auth,Web-Cert-Auth,Web-IP-Security,Web-Url-Auth,Web-Windows-Auth,Web-Static-Content|select DisplayName,@{N='InstallState';E={$_.InstallState -replace "Available","Not Installed"}}|ConvertTo-Csv -Delimiter ";" -NoTypeInformation|ac $File_R4C
}
else{addto-checkcsv-text-arow "NOT INSTALLED" " "}

}catch{addto-checkcsv-text-arow "Comando Get-WindowsFeature " "NOT INSTALLED"}
refresh-progressbar-R4C 63
Add-Content $File_R4C `r
addto-checkcsv-text " " "Verifica Versioni .NET installate"
$Netver = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full' -Name Release).Release
If ($Netver -lt 378389){addto-checkcsv-text-arow " " ".NET Framework precedente 4.5"}
ElseIf ($Netver -eq 378389){addto-checkcsv-text-arow " " ".NET Framework 4.5"}
ElseIf ($Netver -le 378675){addto-checkcsv-text-arow " " ".NET Framework 4.5.1"}
ElseIf ($Netver -le 379893){addto-checkcsv-text-arow " " ".NET Framework 4.5.2"}
ElseIf ($Netver -le 393297){addto-checkcsv-text-arow " " ".NET Framework 4.6"}
ElseIf ($Netver -le 394271){addto-checkcsv-text-arow " " ".NET Framework 4.6.1"}
ElseIf ($Netver -le 394806){addto-checkcsv-text-arow " " ".NET Framework 4.6.2"}
ElseIf ($Netver -le 460805){addto-checkcsv-text-arow " " ".NET Framework 4.7"}
refresh-progressbar-R4C 68
$Label_Report_services.Text = "Servizi: Finished"
$Label_Report_services.ForeColor = "DarkGreen"

$Label_Report_McAfee.Text = "McAfee: In progress"
$Label_Report_McAfee.ForeColor = "Orange"
refresh-progressbar-R4C 70
if ((Get-WmiObject -Class Win32_Service -Filter "Name='McAfeeFramework'") -EQ $null){
addto-checkcsv-text-arow "1.14 Agent antivirus e componenti" "Non presenti"
$Label_Report_McAfee.Text = "McAfee: Not Installed"
$Label_Report_McAfee.ForeColor = "Red"
}
else{
$McAfee_web_check = ((Invoke-WebRequest -Uri http://$env:COMPUTERNAME":8081" -ErrorAction SilentlyContinue|select StatusDescription) -replace '@{StatusDescription=','') -replace '}',''
addto-checkcsv-text "Agent antivirus e componenti"
addto-checkcsv-text-arow "1.14 Portale WEB McAfee" $McAfee_web_check 
addto-checkcsv-text-arow "1.15 Versione McAfee VSE" ((((& "C:\Program Files\Common Files\McAfee\SystemCore\csscan.exe" -Versions) -match "Engine version") -replace "    Engine version: ","")  -replace "\.",";") 
addto-checkcsv-text-arow "1.15 Versione McAfee VSE DAT" ((((& "C:\Program Files\Common Files\McAfee\SystemCore\csscan.exe" -Versions) -match "DAT") -replace "    DAT version:    ","") -replace ".0","")
addto-checkcsv-text " " "1.16 Lista servizi McAfee" 
Get-WmiObject Win32_Service|select Name,State,StartMode|
Where-Object {($_.Name -eq "McAfeeFramework" -or 
$_.Name -eq "macmnsvc" -or
$_.Name -eq "masvc" -or
$_.Name -eq "McShield" -or
$_.Name -eq "mfemms" -or
$_.Name -eq "McTaskManager" -or
$_.Name -eq "mfevtp" -or
$_.Name -eq "HipMgmt"-or
$_.Name -eq "enterceptAgent" -or
$_.Name -eq "mfefire")}|ConvertTo-Csv -Delimiter ";" -NoTypeInformation|ac $File_R4C
$Label_Report_McAfee.Text = "McAfee: Finished"
$Label_Report_McAfee.ForeColor = "DarkGreen"
}
Add-Content $File_R4C `r
addto-checkcsv-text-arow " " " "
Add-Content $File_R4C `r
refresh-progressbar-R4C 75
Add-Content $File_R4C `r
addto-checkcsv-text-arow "1.17 File hosts" " "
((gc C:\Windows\System32\drivers\etc\hosts|Select-String -NotMatch "#.*") -replace " "," ")|ac $File_R4C
if (Get-Command ovc -errorAction SilentlyContinue){
    $Label_Report_agenthp.Text = "Agent HP: In progress"
    $Label_Report_agenthp.ForeColor = "Orange"
    addto-checkcsv-text " " "1.18 Agent HP"
    refresh-progressbar-R4C 78
    ovc -version|ac $File_R4C
    refresh-progressbar-R4C 79
    ovc -status|ac $File_R4C
    refresh-progressbar-R4C 80
    perfstat -p|ac $File_R4C
    refresh-progressbar-R4C 81
    opcagt -version|ac $File_R4C
    ovconfget.exe bbc.http|ac $File_R4C
    refresh-progressbar-R4C 82
    ovconfget.exe bbc.cb|ac $File_R4C
    refresh-progressbar-R4C 83
    ovcert -status|ac $File_R4C
    refresh-progressbar-R4C 85
    ovconfget|findstr CERTIFICATE_SERVER=pscd03c|ac $File_R4C
    $Label_Report_agenthp.Text = "Agent HP: Finished"
    $Label_Report_agenthp.ForeColor = "DarkGreen"}
else{
    addto-checkcsv-text-arow "1.18 Agent HP" "Non presente"
    $Label_Report_agenthp.Text = "Agent HP: Not Installed"
    $Label_Report_agenthp.ForeColor = "Red"
}
Add-Content $File_R4C `r
addto-checkcsv-text-arow " " " "
refresh-progressbar-R4C 88
addto-checkcsv-text-arow "1.20 Stato UAC"
$check_ConsentPromptBehaviorAdmin = (REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"|findstr "ConsentPromptBehaviorAdmin") -replace '    ConsentPromptBehaviorAdmin    REG_DWORD    0x',''
if ($check_ConsentPromptBehaviorAdmin -eq "0" ){addto-checkcsv-text-arow "UAC-ConsentPromptBehaviorAdmin" "OK ($check_ConsentPromptBehaviorAdmin)"}else{addto-checkcsv-text-arow "UAC-ConsentPromptBehaviorAdmin" "KO ($check_ConsentPromptBehaviorAdmin)"}
$check_EnableLUA = (REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"|findstr "EnableLUA") -replace '    EnableLUA    REG_DWORD    0x',''
if ($check_EnableLUA -eq "0" ){addto-checkcsv-text-arow "UAC-EnableLUA" "OK ($check_EnableLUA)"}else{addto-checkcsv-text-arow "UAC-EnableLUA" "KO ($check_EnableLUA)"}
$check_EnableSecureUIAPaths = (REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"|findstr "EnableSecureUIAPaths") -replace '    EnableSecureUIAPaths    REG_DWORD    0x',''
if ($check_EnableSecureUIAPaths -eq "0" ){addto-checkcsv-text-arow "UAC-EnableSecureUIAPaths" "OK ($check_EnableSecureUIAPaths)"}else{addto-checkcsv-text-arow "UAC-EnableSecureUIAPaths" "KO ($check_EnableSecureUIAPaths)"}
$check_EnableInstallerDetection = (REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"|findstr "EnableInstallerDetection") -replace '    EnableInstallerDetection    REG_DWORD    0x',''
if ($check_EnableInstallerDetection -eq "0" ){addto-checkcsv-text-arow "UAC-EnableInstallerDetection" "OK ($check_EnableInstallerDetection)"}else{addto-checkcsv-text-arow "UAC-EnableInstallerDetection" "KO ($check_EnableInstallerDetection)"}
Add-Content $File_R4C `r
addto-checkcsv-text " " "1.20 Stato hardening"
$check_MaxSize = [Convert]::ToInt32(((REG QUERY "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\EventLog\Security"|findstr "MaxSize") -replace '    MaxSize    REG_DWORD    0x',''),16)
if ($check_MaxSize -ge "20971520" ){addto-checkcsv-text-arow "Security-MaxSize" "OK ($check_MaxSize)"}else{addto-checkcsv-text-arow "Security-MaxSize" "KO ($check_MaxSize)"}
$check_restrictnullsessaccess = (REG QUERY "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters"|findstr "restrictnullsessaccess") -replace '    restrictnullsessaccess    REG_DWORD    0x',''
if ($check_restrictnullsessaccess -eq "1" ){addto-checkcsv-text-arow "LanmanServer-restrictnullsessaccess" "OK ($check_restrictnullsessaccess)"}else{addto-checkcsv-text-arow "LanmanServer-restrictnullsessaccess" "KO ($check_restrictnullsessaccess)"}
$check_dontdisplaylastusername = (REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\policies\system"|findstr "dontdisplaylastusername") -replace '    dontdisplaylastusername    REG_DWORD    0x',''
if ($check_dontdisplaylastusername -eq "1" ){addto-checkcsv-text-arow "system-dontdisplaylastusername" "OK ($check_dontdisplaylastusername)"}else{addto-checkcsv-text-arow "system-dontdisplaylastusername" "KO ($check_dontdisplaylastusername)"}
$check_ClearPageFileAtShutdown = (REG QUERY "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"|findstr "ClearPageFileAtShutdown") -replace '    ClearPageFileAtShutdown    REG_DWORD    0x',''
if ($check_ClearPageFileAtShutdown -eq "1" ){addto-checkcsv-text-arow "MemoryMan-ClearPageFileAtShutdown" "OK ($check_ClearPageFileAtShutdown)"}else{addto-checkcsv-text-arow "MemoryMan-ClearPageFileAtShutdown" "KO ($check_ClearPageFileAtShutdown)"}
$check_RestrictAnonymous = ((REG QUERY "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa") -Match "RestrictAnonymous ") -replace '    RestrictAnonymous    REG_DWORD    0x',''
if ($check_RestrictAnonymous -eq "1" ){addto-checkcsv-text-arow "Lsa-RestrictAnonymous" "OK ($check_RestrictAnonymous)"}else{addto-checkcsv-text-arow "Lsa-RestrictAnonymous" "KO ($check_RestrictAnonymous)"}
$check_everyoneincludesanonymous = ((REG QUERY "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa") -Match "everyoneincludesanonymous ") -replace '    everyoneincludesanonymous    REG_DWORD    0x',''
if ($check_everyoneincludesanonymous -eq "1" ){addto-checkcsv-text-arow "Lsa-everyoneincludesanonymous" "OK ($check_everyoneincludesanonymous)"}else{addto-checkcsv-text-arow "Lsa-everyoneincludesanonymous" "KO ($check_everyoneincludesanonymous)"}
$check_DisabledIPv6 = ((REG QUERY "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters") -Match "DisabledComponents") -replace '    DisabledComponents    REG_DWORD    0x',''
if ($check_DisabledIPv6 -eq "ff"){addto-checkcsv-text-arow "Disable-IPv6" "OK ($check_DisabledIPv6)"}else{addto-checkcsv-text-arow "Disable-IPv6" "KO ($check_DisabledIPv6)"}
refresh-progressbar-R4C 90
Add-Content $File_R4C `r
addto-checkcsv-text " " "1.22 Verifica contenuto cartella Temp"
(Get-Childitem "C:\Temp").Name|ac $File_R4C
Add-Content $File_R4C `r
refresh-progressbar-R4C 92
addto-checkcsv-text " " "Verifica configurazione DNS"
(Get-DnsClientServerAddress|where ServerAddresses -NE '{}'|where {$_.ServerAddresses -notmatch "fec0"}).ServerAddresses|sort|Get-Unique -AsString|ac $File_R4C
Add-Content $File_R4C `r
refresh-progressbar-R4C 95
addto-checkcsv-text " " "Verifica raggiungibilita timeserver"
$reply_timeroot = ping -n 1 timeroot.gss.rete.poste | findstr Reply
addto-checkcsv-text $reply_timeroot
$Label_Report_network.Text = "Network: Finished"
$Label_Report_network.ForeColor = "DarkGreen"
refresh-progressbar-R4C 97
addto-checkcsv-text " " "1.23 Verifica presenza ISO/DVD collegate"
addto-checkcsv-text ((Get-WmiObject Win32_CDROMDrive).VolumeName)
addto-checkcsv-text " " "FINE DELLA VERIFICA"
$Button_ViewReport.Enabled = $true
refresh-progressbar-R4C 100
Write-Log -Message "R4C generato"

########################################################################################
###############################functions ConvertToHTML##################################
########################################################################################

Write-Log -Message "Conversione web R4C in corso"
if (Test-Path $File_R4C_web){del $File_R4C_web}

$a = "<style>"
 
$a = $a + "body    { background-color:#FFFFFF; border:0px solid #666666; color:#000000; font-size:100%; font-family:MS Shell Dlg; margin:0,0,10px,0; word-break:normal; word-wrap:break-word; }"
 
$a = $a + "table   { background-color:#E8E8E8; font-size:100%; table-layout:fixed; width:100%; }"
 
$a = $a + "H1  { background-color:#FEF7D6; border:1px solid #BBBBBB; color:#3333CC; cursor:hand; display:block; font-family:MS Shell Dlg; font-size:100%; font-weight:bold; height:2.25em; margin-bottom:-1px; margin-left:0px; margin-right:0px; padding-left:8px; padding-right:5em; padding-top:4px; position:relative; width:100%; }"
 
$a = $a + "td,th  { overflow:visible; text-align:left; vertical-align:top; white-space:normal; }"
 
$a = $a +".title  { background:#FFFFFF; border:none; color:#333333; display:block; height:24px; margin:0px,0px,-1px,0px; padding-top:4px; position:relative; table-layout:fixed; width:100%; z-index:5; }"
$a = $a + "</style>"


$SourceFile = $File_R4C
$TargetFile = $File_R4C_web
$File = Get-Content $SourceFile
$FileLine = @()
Foreach ($Line in $File) {
$MyObject = New-Object -TypeName PSObject
Add-Member -InputObject $MyObject -Type NoteProperty -Name Status -Value $Line
$FileLine += $MyObject
}
$FileLine | ConvertTo-Html  -head $a -body "<H1> Check List_$env:COMPUTERNAME.</H1>  " | Out-File $TargetFile
Write-Log -Message "R4C WEB generato"
Write-Log -Message "Apertura di R4C WEB"
$Browser="c:\Program Files\Internet Explorer\iexplore.exe"
Start-Process $Browser -ArgumentList $File_R4C_web
}



function View-Reporting{
Write-Log -Message "Apertura file $File_R4C"
notepad $File_R4C
}

function Clean-temp{
try{
$intAnswer = $wshell.Popup("Sei sicuro di voler cancellare la Temp?",0,"Warning",4)
If ($intAnswer -eq 6){
    Get-ChildItem -Path "C:\temp" -Recurse -Exclude "$File_R4C_name","$File_R4C_web",$File_wP,$File_wP_conf,$LogFilePath|
    Select -ExpandProperty FullName|
    sort length -Descending|
    Remove-Item -force 
    Write-Log -Message "Pulizia Temp effettuata"
    $wshell.Popup("Pulizia Effettuata",2,"Warning")
    }
else{
    Write-Log -Message "Pulizia Temp annullata" -Severity 2
    $wshell.Popup("Operazione Annullata",2,"Warning")
    }
}catch{Write-Log $_.Exception.Message -Severity 3}
}

########################################################################################
###############################functions TabPageReporting###############################
########################################################################################

#((Get-ChildItem \\10.15.7.113\script\winPlementator\|select Name|Select-String -SimpleMatch wp-ver) -replace "@{Name=wp-ver_","") -replace "}",""

########################################################################################
######################################Define all Objects################################
########################################################################################

########################################################################################
######################################InitializeForm####################################
########################################################################################

[System.Windows.Forms.Application]::EnableVisualStyles()
$Form.AutoSize = $false
$Form.Size = New-Object Drawing.Point 600,400
$Form.StartPosition = "CenterScreen"
$Form.FormBorderStyle = 'Fixed3D'
$Form.Icon = $Icon
$Form.Text = "wP $version_winplementator"

########################################################################################
################################Define and Add form Buttons#############################
########################################################################################
$Button_logout.Location = New-Object Drawing.Point 90,320
$Button_logout.Size = New-Object Drawing.Point 70,30
$Button_logout.text = "Logout"
$Button_logout.add_click({
$intAnswer = $wshell.Popup("Sei sicuro di voler fare il logout?",0,"Warning",4)
If ($intAnswer -eq 6){
    Write-Log -Message "Logout $env:COMPUTERNAME da Winplementator" -Severity 2
    logoff}
else{$wshell.Popup("Operazione Annullata",2,"Warning")}
})

$Button_restart.Location = New-Object Drawing.Point 10,320
$Button_restart.Size = New-Object Drawing.Point 70,30
$Button_restart.text = "Reboot"
$Button_restart.add_click({
$intAnswer = $wshell.Popup("Sei sicuro di voler fare il reboot?",0,"Warning",4)
If ($intAnswer -eq 6){
    Write-Log -Message "Riavvio $env:COMPUTERNAME da Winplementator" -Severity 2
    Restart-Computer}
else{$wshell.Popup("Operazione Annullata",2,"Warning")}
})

$Button_reset_conf.Location = New-Object Drawing.Point 240,320
$Button_reset_conf.Size = New-Object Drawing.Point 120,30
$Button_reset_conf.text = "Reset dones actions"
$Button_reset_conf.add_click({
$intAnswer = $wshell.Popup("Sei sicuro di resettare il File di configurazione?",0,"Warning",4)
If ($intAnswer -eq 6){
    out-file $dir_temp/$File_wP_conf
    Write-Log -Message "Reset File di configurazione di Winplementator completato" -Severity 2
    $wshell.Popup("Reset File di configurazione di Winplementator completato",2,"Warning")
    $wshell.Popup("Chiudere e riaprire winPlementator per ricaricare la configurazione",2,"Warning")
    }
else{$wshell.Popup("Operazione Annullata",2,"Warning")}
})

$Button_close.Location = New-Object Drawing.Point 500,320
$Button_close.Size = New-Object Drawing.Point 70,30
$Button_close.text = "Close"
$Button_close.add_click({Write-Log -Message "Bye bye"
((gc $dir_temp/$File_wP_conf | group|select Name) -replace "@{Name=","") -replace "}",""|Out-File $dir_temp/$File_wP_conf
$Form.close()})


########################################################################################
#################################Define TabControl######################################
########################################################################################

$TabControl.DataBindings.DefaultDataSourceUpdateMode = 0
$TabControl.Location = New-Object Drawing.Point 10,10
$TabControl.Size = New-Object Drawing.Size 560,280
$TabControl.text = "tabControl1"
$TabControl.Name = "tabControl1"
$TabControl.SelectedIndex = 0
$TabControl.ShowToolTips = $True
$TabControl.TabIndex = 7

########################################################################################
################################Define TabPageSecurityHardening#########################
########################################################################################

$TabPageSecurity.DataBindings.DefaultDataSourceUpdateMode = 0
$TabPageSecurity.Location = New-Object Drawing.Point 4,22
$TabPageSecurity.AutoSize =  $true
$TabPageSecurity.Text = "Hardening"
$TabPageSecurity.Name = "Hardening"
$TabPageSecurity.TabIndex = 0
$TabPageSecurity.UseVisualStyleBackColor = $false

########################################################################################
################################Define TabPageSystemVmW#################################
########################################################################################

$TabPageSystem.DataBindings.DefaultDataSourceUpdateMode = 0
$TabPageSystem.Location = New-Object Drawing.Point 4,22
$TabPageSystem.AutoSize =  $true
$TabPageSystem.Text = "Sistema"
$TabPageSystem.Name = "Sistema"
$TabPageSystem.TabIndex = 1
$TabPageSystem.UseVisualStyleBackColor = $false

########################################################################################
#################################Define TabPageNetwork##################################
########################################################################################

$TabPageNetwork.DataBindings.DefaultDataSourceUpdateMode = 0
$TabPageNetwork.Location = New-Object Drawing.Point 4,22
$TabPageNetwork.AutoSize =  $true
$TabPageNetwork.Text = "Network"
$TabPageNetwork.Name = "Network"
$TabPageNetwork.TabIndex = 3
$TabPageNetwork.UseVisualStyleBackColor = $false

########################################################################################
################################Define TabPageServices##################################
########################################################################################

$TabPageServices.DataBindings.DefaultDataSourceUpdateMode = 0
$TabPageServices.Location = New-Object Drawing.Point 4,22
$TabPageServices.AutoSize =  $true
$TabPageServices.Text = "Services & Features"
$TabPageServices.Name = "Servizi"
$TabPageServices.TabIndex = 4
$TabPageServices.UseVisualStyleBackColor = $false

########################################################################################
################################Define TabPageMcAfee####################################
########################################################################################

$TabPageMcAfee.DataBindings.DefaultDataSourceUpdateMode = 0
$TabPageMcAfee.Location = New-Object Drawing.Point 4,22
$TabPageMcAfee.AutoSize =  $true
$TabPageMcAfee.Text = "McAfee"
$TabPageMcAfee.Name = "McAfee"
$TabPageMcAfee.TabIndex = 5
$TabPageMcAfee.UseVisualStyleBackColor = $false

########################################################################################
################################Define TabPageAgentHP###################################
########################################################################################
<#
$TabPageAgentHP.DataBindings.DefaultDataSourceUpdateMode = 0
$TabPageAgentHP.Location = New-Object Drawing.Point 4,22
$TabPageAgentHP.AutoSize =  $true
$TabPageAgentHP.Text = "Agent HP"
$TabPageAgentHP.Name = "Agent HP"
$TabPageAgentHP.TabIndex = 6
$TabPageAgentHP.UseVisualStyleBackColor = $false#>

########################################################################################
################################Define TabPageZabbix###################################
########################################################################################

$TabPageZabbix.DataBindings.DefaultDataSourceUpdateMode = 0
$TabPageZabbix.Location = New-Object Drawing.Point 4, 22
$TabPageZabbix.AutoSize = $true
$TabPageZabbix.Text = "Agent ZABBIX"
$TabPageZabbix.Name = "Agent ZABBIX"
$TabPageZabbix.TabIndex = 6
$TabPageZabbix.UseVisualStyleBackColor = $false

########################################################################################
################################Define TabPageAgentDD###################################
########################################################################################

$TabPageAgentDD.DataBindings.DefaultDataSourceUpdateMode = 0
$TabPageAgentDD.Location = New-Object Drawing.Point 4,22
$TabPageAgentDD.AutoSize =  $true
$TabPageAgentDD.Text = "Agent DD"
$TabPageAgentDD.Name = "Agent DD"
$TabPageAgentDD.TabIndex = 10
$TabPageAgentDD.UseVisualStyleBackColor = $false


########################################################################################
###############################Define TabPageReporting##################################
########################################################################################

$TabPageReporting.DataBindings.DefaultDataSourceUpdateMode = 0
$TabPageReporting.Location = New-Object Drawing.Point 4,22
$TabPageReporting.AutoSize =  $true
$TabPageReporting.Text = "Reporting"
$TabPageReporting.Name = "Reporting"
$TabPageReporting.TabIndex = 7
$TabPageReporting.UseVisualStyleBackColor = $false

########################################################################################
###################################Define TabPageAbout##################################
########################################################################################

$TabPageAbout.DataBindings.DefaultDataSourceUpdateMode = 0
$TabPageAbout.Location = New-Object Drawing.Point 4,22
$TabPageAbout.AutoSize =  $true
$TabPageAbout.Text = "info"
$TabPageAbout.Name = "info"
$TabPageAbout.TabIndex = 8
$TabPageAbout.UseVisualStyleBackColor = $false

########################################################################################
################################ContentTabPageSecurityHardening#########################
########################################################################################

$GroupBox_hardening.Location = New-Object Drawing.Point 75,50
$GroupBox_hardening.Size = New-Object Drawing.Size 410,150
$GroupBox_hardening.text = "STEP 1 - inizia da qui"

$Button_apply_hardening.Location = New-Object Drawing.Point 100,40
$Button_apply_hardening.Size = New-Object Drawing.Size  220,40
$Button_apply_hardening.Text = "APPLICA HARDENING"
$Button_apply_hardening.add_click({write-tofile-conf Button_apply_hardening;apply-hardening-policy})
#$Button_apply_hardening.ForeColor = "#c11b1b"
$Button_apply_hardening.Font = New-Object System.Drawing.Font("Microsoft Sans Serif", 10, [System.Drawing.FontStyle]::Bold)
$Label_hard.Location = New-Object Drawing.Point 70, 20
$Label_hard.Size = New-Object Drawing.Size 400, 75
$Label_hard.TextAlign = "TopCenter"
$Label_hard.text = "Hardening applies all security policies "

$Button_iiscrypto.Location = New-Object Drawing.Point 220, 220
$Button_iiscrypto.Size = New-Object Drawing.Size  130, 30
$Button_iiscrypto.Text = "IIS CRYPTO TOOL"
$Button_iiscrypto.add_click({ write-tofile-conf Button_iiscrypto; iiscrypto })
$Label_iiscrypto.Location = New-Object Drawing.Point 75, 205
$Label_iiscrypto.Size = New-Object Drawing.Size 400, 75
$Label_iiscrypto.TextAlign = "TopCenter"
$Label_iiscrypto.text = "IIS Tool show and modify TLS and Ciphers security protocol"


#$Button_set_swap.Location = New-Object System.Drawing.Point 140,100
#$Button_set_swap.Size = New-Object System.Drawing.Size 130,30
#$Button_set_swap.text = "SET SWAP a 4GB"
#$Button_set_swap.add_click({write-tofile-conf Button_set_swap;Set-PageFile})

########################################################################################
##################################ContentTabPageSystemVMW###############################
########################################################################################

$GroupBox_VmW.Location = New-Object Drawing.Point 10,8
$GroupBox_VmW.Size = New-Object Drawing.Size 290,230
$GroupBox_VmW.text = "Per Sistemi VmWare"

$GroupBox_domain.Location = New-Object Drawing.Point 144,8
$GroupBox_domain.Size = New-Object Drawing.Size 140,215
$GroupBox_domain.text = "Domain"

$GroupBox_azure.Location = New-Object Drawing.Point 320,8
$GroupBox_azure.Size = New-Object Drawing.Size 190,230
$GroupBox_azure.text = "Per Sistemi Azure"

$TextBox_hostname.Location = New-Object System.Drawing.Point 15,28
$TextBox_hostname.Size = New-Object System.Drawing.Size 130,40
$TextBox_hostname.text = $env:COMPUTERNAME
#give the control a name
$TextBox_hostname.name="text1"
#connect the ShowHelp scriptblock with the _MouseHover event for this control
$TextBox_hostname.add_MouseHover($ShowHelp)
#$form1.controls.add($text1)

$Button_changehn.Location = New-Object Drawing.Point 15,50
$Button_changehn.Size = New-Object Drawing.Point 130,25
$Button_changehn.text = "Modifica hostname"
$Button_changehn.add_click({write-tofile-conf Button_changehn;Rename-hostname})

$Button_admin_changes.Location = New-Object System.Drawing.Point 15,80
$Button_admin_changes.Size = New-Object System.Drawing.Size 130,40
$Button_admin_changes.text = "Modifica Administrator/Guest"
$Button_admin_changes.add_click({write-tofile-conf Button_admin_changes;rename-administrator})

$Button_regional_custom.Location = New-Object System.Drawing.Point 15,130
$Button_regional_custom.Size = New-Object System.Drawing.Size 130,40
$Button_regional_custom.text = "Modifica parametri regionali"
$Button_regional_custom.add_click({write-tofile-conf Button_regional_custom;Regional-custom})

$Button_resize_disk.Location = New-Object System.Drawing.Point 15,180
$Button_resize_disk.Size = New-Object System.Drawing.Point 130,40
$Button_resize_disk.text = "Resize Disco di sistema"
$Button_resize_disk.add_click({write-tofile-conf Button_resize_disk;resize-systemdisk})

$DropDown_domains.Location = New-Object System.Drawing.Point 160,32
$DropDown_domains.Size = New-Object System.Drawing.Size 130,40
$DropDown_domains.Text = (gwmi WIN32_ComputerSystem).Domain

$TextBox_username.Location = New-Object System.Drawing.Point 160,55
$TextBox_username.Size = New-Object System.Drawing.Size 130,40
$TextBox_username.text = "Inserire utente di dominio"

$TextBox_password.Location = New-Object System.Drawing.Point 160,80
$TextBox_password.Size = New-Object System.Drawing.Size 130,40
$TextBox_password.text = "11111111"
$TextBox_password.PasswordChar = '*'

$Button_joindomain.Location = New-Object Drawing.Point 160,100
$Button_joindomain.Size = New-Object Drawing.Point 130,25
$Button_joindomain.text = "Join Dominio"
$Button_joindomain.add_click({write-tofile-conf Button_joindomain;join-domain})

$Button_admin_home.Location = New-Object System.Drawing.Point 160,180
$Button_admin_home.Size = New-Object System.Drawing.Size 130,40
$Button_admin_home.text = "Rimozione home Sfiadmsm"
$Button_admin_home.add_click({write-tofile-conf Button_admin_home;remove-home-admin})

$Button_groups_and_user_add.Location = New-Object System.Drawing.Point 160,130
$Button_groups_and_user_add.Size = New-Object System.Drawing.Size 130,40
$Button_groups_and_user_add.text = "Aggiunta gruppi ed utenti in administrators"
$Button_groups_and_user_add.add_click({write-tofile-conf Button_groups_and_user_add;add-group-admins})
##azure##
$Button_admin_changes2.Location = New-Object System.Drawing.Point 350,30
$Button_admin_changes2.Size = New-Object System.Drawing.Size 130,40
$Button_admin_changes2.text = "Modifica Posteadmin"
$Button_admin_changes2.add_click({write-tofile-conf Button_admin_changes2;rename-administrator})

$Button_regional_custom2.Location = New-Object System.Drawing.Point 350,80
$Button_regional_custom2.Size = New-Object System.Drawing.Size 130,40
$Button_regional_custom2.text = "Modifica parametri regionali"
$Button_regional_custom2.add_click({write-tofile-conf Button_regional_custom2;Regional-custom})

$Button_groups_and_user_add2.Location = New-Object System.Drawing.Point 350,130
$Button_groups_and_user_add2.Size = New-Object System.Drawing.Size 130,40
$Button_groups_and_user_add2.text = "Aggiunta gruppi ed utenti in administrators"
$Button_groups_and_user_add2.add_click({write-tofile-conf Button_groups_and_user_add2;add-group-admins})

$Button_admin_home2.Location = New-Object System.Drawing.Point 350,180
$Button_admin_home2.Size = New-Object System.Drawing.Size 130,40
$Button_admin_home2.text = "Rimozione home Sfiadmsm"
$Button_admin_home2.add_click({write-tofile-conf Button_admin_home2;remove-home-admin})

########################################################################################
##################################ContentTabPageNetwork#################################
########################################################################################

$Label_currentnics.Location = New-Object System.Drawing.Point 10,10
$Label_currentnics.Size =  New-Object System.Drawing.Size 130,15
$Label_currentnics.Text = "Lista Nomi NIC correnti"

$DropDown_listnics.Location = New-Object System.Drawing.Point 10,25
$DropDown_listnics.Size = New-Object System.Drawing.Size 130,40
$DropDown_listnics.Sorted = $true
$DropDown_listnics.DropDownStyle = "DropDownList"

$Button_refresh_list_nic.Location = New-Object Drawing.Point 10,50
$Button_refresh_list_nic.Size = New-Object Drawing.Point 130,20
$Button_refresh_list_nic.text = "Refresh Lista NIC"
$Button_refresh_list_nic.add_click({write-tofile-conf Button_refresh_list_nic;get-listnics})

$Label_modifiednamenic.Location = New-Object System.Drawing.Point 10,70
$Label_modifiednamenic.Size =  New-Object System.Drawing.Size 130,15
$Label_modifiednamenic.Text = "Modifica nome NIC in"

$DropDown_modifiednamenic.Location = New-Object System.Drawing.Point 10,85
$DropDown_modifiednamenic.Size = New-Object System.Drawing.Size 130,40
$DropDown_modifiednamenic.Sorted = $true

$Button_change_name_nic.Location = New-Object Drawing.Point 10,110
$Button_change_name_nic.Size = New-Object Drawing.Point 130,20
$Button_change_name_nic.text = "Modifica Nome NIC"
$Button_change_name_nic.add_click({write-tofile-conf Button_change_name_nic;Rename-nic})

$GroupBox_set_ipaddr.Location = New-Object System.Drawing.Size 145,10
$GroupBox_set_ipaddr.size = New-Object System.Drawing.Size 145,145
$GroupBox_set_ipaddr.text = "Config Network NIC"

$Label_ipaddr.Location = New-Object System.Drawing.Size 5,18
$Label_ipaddr.size = New-Object System.Drawing.Size 18,15
$Label_ipaddr.text = "IP:"

$TextBox_ipaddr1.Location = New-Object System.Drawing.Point 23,15
$TextBox_ipaddr1.Size = New-Object System.Drawing.Size 25,30
$TextBox_ipaddr1.MaxLength = "3"
$TextBox_ipaddr1.text = "10"
add-dot-GroupBox-set-ipaddr 48 20

$TextBox_ipaddr2.Location = New-Object System.Drawing.Point 53,15
$TextBox_ipaddr2.Size = New-Object System.Drawing.Size 25,30
$TextBox_ipaddr2.MaxLength = "3"
$TextBox_ipaddr2.text = ""
add-dot-GroupBox-set-ipaddr 79 20

$TextBox_ipaddr3.Location = New-Object System.Drawing.Point 84,15
$TextBox_ipaddr3.Size = New-Object System.Drawing.Size 25,30
$TextBox_ipaddr3.MaxLength = "3"
$TextBox_ipaddr3.text = ""
add-dot-GroupBox-set-ipaddr 110 20

$TextBox_ipaddr4.Location = New-Object System.Drawing.Point 115,15
$TextBox_ipaddr4.Size = New-Object System.Drawing.Size 25,30
$TextBox_ipaddr4.MaxLength = "3"
$TextBox_ipaddr4.text = ""

$Label_Netmask.Location = New-Object System.Drawing.Size 5,35
$Label_Netmask.size = New-Object System.Drawing.Size 65,15
$Label_Netmask.text = "Netmask:"

$DropDown_netmask.Location = New-Object System.Drawing.Point 5,50
$DropDown_netmask.Size = New-Object System.Drawing.Size 135,40
$DropDown_netmask.DropDownStyle = "DropDownList"
$DropDown_netmask.Sorted = $false

$Label_gw.Location = New-Object System.Drawing.Size 3,72
$Label_gw.size = New-Object System.Drawing.Size 18,30
$Label_gw.text = "GW:"

$TextBox_gw1.Location = New-Object System.Drawing.Point 23,77
$TextBox_gw1.Size = New-Object System.Drawing.Size 25,30
$TextBox_gw1.MaxLength = "3"
$TextBox_gw1.text = "10"
add-dot-GroupBox-set-ipaddr 48 82

$TextBox_gw2.Location = New-Object System.Drawing.Point 53,77
$TextBox_gw2.Size = New-Object System.Drawing.Size 25,30
$TextBox_gw2.MaxLength = "3"
$TextBox_gw2.text = ""
add-dot-GroupBox-set-ipaddr 79 82

$TextBox_gw3.Location = New-Object System.Drawing.Point 84,77
$TextBox_gw3.Size = New-Object System.Drawing.Size 25,30
$TextBox_gw3.MaxLength = "3"
$TextBox_gw3.text = ""
add-dot-GroupBox-set-ipaddr 110 82

$TextBox_gw4.Location = New-Object System.Drawing.Point 115,77
$TextBox_gw4.Size = New-Object System.Drawing.Size 25,30
$TextBox_gw4.MaxLength = "3"
$TextBox_gw4.text = ""

$Button_setipaddr.Location = New-Object Drawing.Point 8,105
$Button_setipaddr.Size = New-Object Drawing.Point 60,35
$Button_setipaddr.text = "Imposta* IP statico"
$Button_setipaddr.add_click({write-tofile-conf Button_setipaddr;set-networknic "static"})

$Button_setdhcp.Location = New-Object Drawing.Point 78,105
$Button_setdhcp.Size = New-Object Drawing.Point 60,35
$Button_setdhcp.text = "Imposta* IP DHCP"
$Button_setdhcp.add_click({write-tofile-conf Button_setdhcp;set-networknic "dhcp"})

$Button_binding_nic.Location = New-Object Drawing.Point 295,10
$Button_binding_nic.Size = New-Object Drawing.Point 130,35
$Button_binding_nic.text = "Modifica Binding NIC"
$Button_binding_nic.add_click({write-tofile-conf Button_binding_nic;Binding-nic})

$Button_reset_nonpresent_nic.Location = New-Object Drawing.Point 295,50
$Button_reset_nonpresent_nic.Size = New-Object Drawing.Point 130,35
$Button_reset_nonpresent_nic.text = "Pulizia conf NIC non presenti"
$Button_reset_nonpresent_nic.add_click({write-tofile-conf Button_reset_nonpresent_nic;reset-nonpresent-nic})

$GroupBox_dns.Location = New-Object System.Drawing.Size 10,150
$GroupBox_dns.size = New-Object System.Drawing.Size 270,95
$GroupBox_dns.text = "Impostazione DNS"

$Button_dns_prod_nord.Location = New-Object Drawing.Point 3,15
$Button_dns_prod_nord.Size = New-Object Drawing.Point 83,35
$Button_dns_prod_nord.text = "Produzione NORD*"
$Button_dns_prod_nord.add_click({write-tofile-conf Button_dns_prod_nord;configure-dns(1)})

$Button_dns_prod_center.Location = New-Object Drawing.Point 3,55
$Button_dns_prod_center.Size = New-Object Drawing.Point 83,35
$Button_dns_prod_center.text = "Produzione CENTRO*"
$Button_dns_prod_center.add_click({write-tofile-conf Button_dns_prod_center;configure-dns(2)})

$Button_dns_prod_south.Location = New-Object Drawing.Point 93,15
$Button_dns_prod_south.Size = New-Object Drawing.Point 83,35
$Button_dns_prod_south.text = "Produzione SUD*"
$Button_dns_prod_south.add_click({write-tofile-conf Button_dns_prod_south;configure-dns(3)})

$Button_dns_cert.Location = New-Object Drawing.Point 93,55
$Button_dns_cert.Size = New-Object Drawing.Point 83,35
$Button_dns_cert.text = "Certificazione*"
$Button_dns_cert.add_click({write-tofile-conf Button_dns_cert;configure-dns(4)})

$Button_dns_svil.Location = New-Object Drawing.Point 183,15
$Button_dns_svil.Size = New-Object Drawing.Point 83,35
$Button_dns_svil.text = "Sviluppo*"
$Button_dns_svil.add_click({write-tofile-conf Button_dns_svil;configure-dns(5)})

$Button_dns_mgmt.Location = New-Object Drawing.Point 183,55
$Button_dns_mgmt.Size = New-Object Drawing.Point 83,35
$Button_dns_mgmt.text = "Management*"
$Button_dns_mgmt.add_click({write-tofile-conf Button_dns_mgmt;configure-dns(6)})

$Label_notice_dns.Location = New-Object System.Drawing.Point 280,220
$Label_notice_dns.Size =  New-Object System.Drawing.Size 150,45
$Label_notice_dns.Text = '*I bottoni fanno riferimento a'+"`n"+'   "Lista Nomi NIC correnti"'

########################################################################################
#################################ContentTabPageServices#################################
########################################################################################

$GroupBox_services.Location = New-Object System.Drawing.Size 10,10
$GroupBox_services.size = New-Object System.Drawing.Size 120,230
$GroupBox_services.text = "Services/Agent"

$Button_firewall_disable.Location = New-Object Drawing.Point 10,15
$Button_firewall_disable.Size = New-Object Drawing.Size 100,40
$Button_firewall_disable.text = "Disable Firewall"
$Button_firewall_disable.add_click({write-tofile-conf Button_firewall_disable;firewall-disable})

$Button_rdp_enable.Location = New-Object Drawing.Point 10,65
$Button_rdp_enable.Size = New-Object Drawing.Size 100,40
$Button_rdp_enable.text = "Enable RDP"
$Button_rdp_enable.add_click({write-tofile-conf Button_rdp_enable;rdp-enable})

$GroupBox_evf.Location = New-Object System.Drawing.Size 150,10
$GroupBox_evf.size = New-Object System.Drawing.Size 390,230
$GroupBox_evf.text = "Event Forwarding LMS"

$Button_evf_to1.Location = New-Object Drawing.Point 10,15
$Button_evf_to1.Size = New-Object Drawing.Size 90,30
$Button_evf_to1.text = "TORINO/AZURE 1"
$Button_evf_to1.font = 'Microsoft Sans Serif,7'
$Button_evf_to1.add_click({write-tofile-conf Button_evf_to1;evf-to1})

$Label_to1.Font = 'Microsoft Sans Serif,7'
$Label_to1.Location = New-Object System.Drawing.Point 100,18
$Label_to1.Size =  New-Object System.Drawing.Size 270,40
$Label_to1.Text = 'da PA a PM (es: PBDMDB01V,PHPSDB01V)'

$Button_evf_to2.Location = New-Object Drawing.Point 10,55
$Button_evf_to2.Size = New-Object Drawing.Size 90,30
$Button_evf_to2.text = "TORINO/AZURE 2"
$Button_evf_to2.font = 'Microsoft Sans Serif,7'
$Button_evf_to2.add_click({write-tofile-conf Button_evf_to1;evf-to2})

$Label_to2.Font = 'Microsoft Sans Serif,7'
$Label_to2.Location = New-Object System.Drawing.Point 100,58
$Label_to2.Size =  New-Object System.Drawing.Size 270,40
$Label_to2.Text = 'da PN a PZ (es: PTLFMDB01V) o non iniziano per P (es: DCPTHYPWEB03)'

$Button_evf_po.Location = New-Object Drawing.Point 10,95
$Button_evf_po.Size = New-Object Drawing.Size 90,30
$Button_evf_po.text = "POMEZIA"
$Button_evf_po.font = 'Microsoft Sans Serif,7'
$Button_evf_po.add_click({write-tofile-conf Button_evf_to1;evf-po})

$Button_evf_ro.Location = New-Object Drawing.Point 10,135
$Button_evf_ro.Size = New-Object Drawing.Size 90,30
$Button_evf_ro.text = "ROZZANO"
$Button_evf_ro.font = 'Microsoft Sans Serif,7'
$Button_evf_ro.add_click({write-tofile-conf Button_evf_to1;evf-ro})

$Button_evf_co.Location = New-Object Drawing.Point 10,175
$Button_evf_co.Size = New-Object Drawing.Size 90,30
$Button_evf_co.text = "CONGRESSI"
$Button_evf_co.font = 'Microsoft Sans Serif,7'
$Button_evf_co.add_click({write-tofile-conf Button_evf_to1;evf-co})

#$TextBox_key.Location = New-Object System.Drawing.Point 10,15
#$TextBox_key.Size = New-Object System.Drawing.Size 200,30
#$TextBox_key.MaxLength = "35"
#$TextBox_key.text = "AAAAA-BBBBB-CCCCC-DDDDD-EEEEE"

#$Button_act_kms.Location = New-Object Drawing.Point 10,40
#$Button_act_kms.Size = New-Object Drawing.Size 60,30
#$Button_act_kms.text = "Act KMS"
#$Button_act_kms.add_click({write-tofile-conf Button_act_kms;})
#
#$Button_act_mak.Location = New-Object Drawing.Point 150,40
#$Button_act_mak.Size = New-Object Drawing.Size 60,30
#$Button_act_mak.text = "Act MAK"
#$Button_act_mak.add_click({write-tofile-conf Button_act_mak;act-mak})

########################################################################################
################################ContentTabPageMcAfee####################################
########################################################################################

$GroupBox_McAfee.Location = New-Object Drawing.Point 70,55
$GroupBox_McAfee.Size = New-Object Drawing.Size 410,130
$GroupBox_McAfee.text = "Installers McAfee"

$GroupBox_agent_McAfee.Location = New-Object Drawing.Point 15,15
$GroupBox_agent_McAfee.Size = New-Object Drawing.Size 380,60
$GroupBox_agent_McAfee.text = "Agent McAfee 5.7.2"

$Button_agent_McAfee_svil.Location = New-Object Drawing.Point 5,15
$Button_agent_McAfee_svil.Size = New-Object Drawing.Size 120,40
$Button_agent_McAfee_svil.Text = "Agent Sviluppo 5.7.4"
$Button_agent_McAfee_svil.add_click({write-tofile-conf Button_agent_McAfee_svil;agent-McAfee(1)})

$Button_agent_McAfee_cert.Location = New-Object Drawing.Point 130,15
$Button_agent_McAfee_cert.Size = New-Object Drawing.Size 120,40
$Button_agent_McAfee_cert.Text = "Agent Certificazione"
$Button_agent_McAfee_cert.add_click({write-tofile-conf Button_agent_McAfee_cert;agent-McAfee(2)})

$Button_agent_McAfee_prod.Location = New-Object Drawing.Point 255,15
$Button_agent_McAfee_prod.Size = New-Object Drawing.Size 120,40
$Button_agent_McAfee_prod.Text = "Agent Produzione"
$Button_agent_McAfee_prod.add_click({write-tofile-conf Button_agent_McAfee_prod;agent-McAfee(3)})

$Button_engine_McAfee.Location = New-Object Drawing.Point 145,80
$Button_engine_McAfee.Size = New-Object Drawing.Size  120,40
$Button_engine_McAfee.Text = "Engine ENS 10.7 McAfee"
$Button_engine_McAfee.add_click({write-tofile-conf Button_engine_McAfee;engine-McAfee})

########################################################################################
#################################ContentTabPageAgentHP##################################
########################################################################################

<#$Label_selectip_agenthp.location = New-Object System.Drawing.Point 10,10
$Label_selectip_agenthp.Size = New-Object System.Drawing.Size 130,15
$Label_selectip_agenthp.text = "Seleziona IP erogazione"

$DropDown_listip.Location = New-Object System.Drawing.Point 10,25
$DropDown_listip.Size = New-Object System.Drawing.Size 130,40
$DropDown_listip.DropDownStyle = "DropDownList"

$Button_configure_hostsfile.Location = New-Object Drawing.Point 10,55
$Button_configure_hostsfile.Size = New-Object Drawing.Size 130,40
$Button_configure_hostsfile.Text = "Configurazione file hosts"
$Button_configure_hostsfile.add_click({write-tofile-conf Button_configure_hostsfile;configure-hostsfile})

$Button_agenthp_install.Location = New-Object System.Drawing.Point 10,105
$Button_agenthp_install.Size = New-Object System.Drawing.Size 130,40
$Button_agenthp_install.text = "Installazione Agent HP"
$Button_agenthp_install.add_click({write-tofile-conf Button_agenthp_install;Install-AgentHP})

$GroupBox_agenthp_configure.Location = New-Object Drawing.Point 5,150
$GroupBox_agenthp_configure.Size = New-Object Drawing.Size 140,87
$GroupBox_agenthp_configure.text = "Configurazione Agent HP"

$Button_agenthp_configure.Location = New-Object System.Drawing.Point 5,15
$Button_agenthp_configure.Size = New-Object System.Drawing.Size 130,30
$Button_agenthp_configure.text = "Avvio Configurazione"
$Button_agenthp_configure.add_click({write-tofile-conf Button_agenthp_configure;Configure-AgentHP})

$Label_agenthp_configure_progressbar.Location = New-Object System.Drawing.Point 5,45
$Label_agenthp_configure_progressbar.Size = New-Object System.Drawing.Size 130,15
$Label_agenthp_configure_progressbar.text = "Stato Configurazione:"
$Label_agenthp_configure_progressbar.Enabled = $false

$progressBar_agenthp_configure.Location = New-Object System.Drawing.Point 5,60
$progressBar_agenthp_configure.Size = New-Object Drawing.Size 130,20
$progressBar_agenthp_configure.Enabled = $false

$GroupBox_agenthp_verify.Location = New-Object Drawing.Point 155,10
$GroupBox_agenthp_verify.Size = New-Object Drawing.Size 270,225
$GroupBox_agenthp_verify.text = "Verifica Agent HP"

$Button_agenthp_verify.Location = New-Object System.Drawing.Point 5,15
$Button_agenthp_verify.Size = New-Object System.Drawing.Size 130,40
$Button_agenthp_verify.text = "Controllo Configurazione"
$Button_agenthp_verify.add_click({write-tofile-conf Button_agenthp_verify;Verify-AgentHP})

$RichTextBox_agenthp_verify.Location = New-Object System.Drawing.Point 5,57
$RichTextBox_agenthp_verify.Size = New-Object System.Drawing.Size 260, 163
#>
########################################################################################
################################ContentTabPageZabbix####################################
########################################################################################

$GroupBox_zabbix.Location = New-Object Drawing.Point 40, 20
$GroupBox_zabbix.Size = New-Object Drawing.Size 470, 200
$GroupBox_zabbix.text = "Installers Zabbix Agent"

$Button_zabbix_prod_install.Location = New-Object Drawing.Point 50, 60
$Button_zabbix_prod_install.Size = New-Object Drawing.Size 120, 60
$Button_zabbix_prod_install.Text = "ZABBIX PROD"
$Button_zabbix_prod_install.add_click({ write-tofile-conf Button_zabbix_prod_install; Install-Zabbix_prod(2) })

$Button_zabbix_cert_install.Location = New-Object Drawing.Point 300, 60
$Button_zabbix_cert_install.Size = New-Object Drawing.Size 120, 60
$Button_zabbix_cert_install.Text = "ZABBIX CERT"
$Button_zabbix_cert_install.add_click({ write-tofile-conf Button_zabbix_cert_install; Install-Zabbix_cert(3) })


########################################################################################
#################################ContentTabPageAgentDD##################################
########################################################################################

#$DropDown_listip.Location = New-Object System.Drawing.Point 10,25
#$DropDown_listip.Size = New-Object System.Drawing.Size 130,40
#$DropDown_listip.DropDownStyle = "DropDownList"

$DropDown_EnvTAG.Location = New-Object System.Drawing.Point 20,75
$DropDown_EnvTAG.Size = New-Object System.Drawing.Size 100,40
$DropDown_EnvTAG.Sorted = $true
$DropDown_EnvTAG.DropDownStyle = "DropDownList"

$Label_TAG_ENV.location = New-Object System.Drawing.Point 20,60
$Label_TAG_ENV.Size = New-Object System.Drawing.Size 120,15
$Label_TAG_ENV.text = "TAG Env (Ambiente)"

$DropDown_SiteTAG.Location = New-Object System.Drawing.Point 20,120
$DropDown_SiteTAG.Size = New-Object System.Drawing.Size 100,40
$DropDown_SiteTAG.Sorted = $true
$DropDown_SiteTAG.DropDownStyle = "DropDownList"

$Label_TAG_Site.location = New-Object System.Drawing.Point 20,105
$Label_TAG_Site.Size = New-Object System.Drawing.Size 120,15
$Label_TAG_Site.text = "TAG Site"

$DropDown_TypeTAG.Location = New-Object System.Drawing.Point 140,120
$DropDown_TypeTAG.Size = New-Object System.Drawing.Size 100,40
$DropDown_TypeTAG.Sorted = $true
$DropDown_TypeTAG.DropDownStyle = "DropDownList"

$Label_TAG_Type.location = New-Object System.Drawing.Point 140,105
$Label_TAG_Type.Size = New-Object System.Drawing.Size 120,15
$Label_TAG_Type.text = "TAG Type"

$DropDown_AvailabilityTAG.Location = New-Object System.Drawing.Point 140,75
$DropDown_AvailabilityTAG.Size = New-Object System.Drawing.Size 100,40
$DropDown_AvailabilityTAG.Sorted = $true
$DropDown_AvailabilityTAG.DropDownStyle = "DropDownList"

$Label_TAG_Availability.location = New-Object System.Drawing.Point 140,60
$Label_TAG_Availability.Size = New-Object System.Drawing.Size 120,15
$Label_TAG_Availability.text = "TAG Availability"

$DropDown_RoleTAG.Location = New-Object System.Drawing.Point 260,75
$DropDown_RoleTAG.Size = New-Object System.Drawing.Size 100,40
$DropDown_RoleTAG.Sorted = $true
$DropDown_RoleTAG.DropDownStyle = "DropDownList"

$Label_TAG_Role.location = New-Object System.Drawing.Point 260,60
$Label_TAG_Role.Size = New-Object System.Drawing.Size 120,15
$Label_TAG_Role.text = "TAG Role"

$Button_configure_proxyprod.Location = New-Object Drawing.Point 10,25
$Button_configure_proxyprod.Size = New-Object Drawing.Size 130,40
$Button_configure_proxyprod.Text = "Configurazione proxy PROD"
$Button_configure_proxyprod.add_click({write-tofile-conf Button_configure_proxyprod;configure-proxyprod})

$Button_configure_proxycert.Location = New-Object Drawing.Point 10,105
$Button_configure_proxycert.Size = New-Object Drawing.Size 130,40
$Button_configure_proxycert.Text = "Configurazione proxy CERT"
$Button_configure_proxycert.add_click({write-tofile-conf Button_configure_proxycert;configure-proxycert})

$Button_AgentDD_install.Location = New-Object System.Drawing.Point 100,190
$Button_AgentDD_install.Size = New-Object System.Drawing.Size 130,40
$Button_AgentDD_install.text = "Installazione Agent DD"
$Button_AgentDD_install.add_click({write-tofile-conf Button_AgentDD_install;Install-AgentDD})

$Button_checkproxycert.Location = New-Object Drawing.Point 10,145
$Button_checkproxycert.Size = New-Object Drawing.Size 130,25
$Button_checkproxycert.Text = "Check proxy CERT"
$Button_checkproxycert.add_click({write-tofile-conf Button_checkproxycert;checkproxycert})

$Button_checkproxyprod.Location = New-Object Drawing.Point 10,65
$Button_checkproxyprod.Size = New-Object Drawing.Size 130,25
$Button_checkproxyprod.Text = "Check proxy PROD"
$Button_checkproxyprod.add_click({write-tofile-conf Button_checkproxyprod;checkproxyprod})

$Button_restart_AgentDD.Location = New-Object Drawing.Point 25,190
$Button_restart_AgentDD.Size = New-Object Drawing.Size 100,30
$Button_restart_AgentDD.Text = "RESTART Agent"
$Button_restart_AgentDD.add_click({write-tofile-conf Button_restart_AgentDD;restart-agentDD})

#$Button_stop_AgentDD.Location = New-Object Drawing.Point 80,190
#$Button_stop_AgentDD.Size = New-Object Drawing.Size 60,40
#$Button_stop_AgentDD.Text = "STOP Agent"

$Button_DDgui.Location = New-Object Drawing.Point 235,190
$Button_DDgui.Size = New-Object Drawing.Size 60,40
$Button_DDgui.Text = "Launch GUI"
$Button_DDgui.add_click({write-tofile-conf Button_DDgui;startgui})

$Button_removeDD.Location = New-Object Drawing.Point 295,190
$Button_removeDD.Size = New-Object Drawing.Size 60,40
$Button_removeDD.Text = "Remove Agent"
$Button_removeDD.add_click({write-tofile-conf Button_removeDD;remove-DD})

$GroupBox_AgentDD_TAG.Location = New-Object Drawing.Point 150,5
$GroupBox_AgentDD_TAG.Size = New-Object Drawing.Size 370,240
$GroupBox_AgentDD_TAG.text = "Configurazione TAG Agent DD su $env:COMPUTERNAME"

$TextBox_service.Location = New-Object System.Drawing.Point 20,35
$TextBox_service.Size = New-Object System.Drawing.Size 300,40
$TextBox_service.text = ""

$Label_TAG_Service.location = New-Object System.Drawing.Point 20,20
$Label_TAG_Service.Size = New-Object System.Drawing.Size 100,15
$Label_TAG_Service.text = "Servizio Operativo"

$Label_TAG_info.location = New-Object System.Drawing.Point 15,160
$Label_TAG_info.Size = New-Object System.Drawing.Size 350,20
$Label_TAG_info.text = "Prima di procedere con l'installazione INSERIRE I DATI TAG!"
$Label_TAG_info.Font = new-object System.Drawing.Font("Microsoft Sans Serif", 8, [System.Drawing.FontStyle]::Bold)
$Label_TAG_info.ForeColor ='red'
$Label_TAG_info.AutoSize = $True

#$Label_TAG_Service.Enabled = $false
#
#$RichTextBox_DD_verify.Location = New-Object System.Drawing.Point 160,57
#$RichTextBox_DD_verify.Size = New-Object System.Drawing.Size 160,163

#$Button_DD_configure.Location = New-Object System.Drawing.Point 5,15
#$Button_DD_configure.Size = New-Object System.Drawing.Size 130,30
#$Button_DD_configure.text = "Avvio Configurazione"
#$Button_DD_configure.add_click({write-tofile-conf Button_agenthp_configure;Configure-AgentHP})

#$progressBar_agenthp_configure.Location = New-Object System.Drawing.Point 5,60
#$progressBar_agenthp_configure.Size = New-Object Drawing.Size 130,20
#$progressBar_agenthp_configure.Enabled = $false

#$GroupBox_AgentDD_verify.Location = New-Object Drawing.Point 155,10
#$GroupBox_AgentDD_verify.Size = New-Object Drawing.Size 270,225
#$GroupBox_AgentDD_verify.text = "Verifica Agent DD"

#$Button_DD_verify.Location = New-Object System.Drawing.Point 5,15
#$Button_DD_verify.Size = New-Object System.Drawing.Size 130,40
#$Button_DD_verify.text = "Controllo Configurazione"
#$Button_DD_verify.add_click({write-tofile-conf Button_DD_verify;Verify-AgentHP})



########################################################################################
#################################ContentTabPageReporting################################
########################################################################################

$GroupBox_temp_dir.Location = New-Object Drawing.Point 10,10
$GroupBox_temp_dir.Size = New-Object Drawing.Size 155,52
$GroupBox_temp_dir.text = "Temp Directory Action"

$Button_open_temp.Location = New-Object Drawing.Point 5,15
$Button_open_temp.Size = New-Object Drawing.Size 65,30
$Button_open_temp.text = "Open"
$Button_open_temp.add_click({write-tofile-conf Button_open_temp;explorer C:\temp})

$Button_clean_temp.Location = New-Object Drawing.Point 80,15
$Button_clean_temp.Size = New-Object Drawing.Size 65,30
$Button_clean_temp.text = "Clear"
$Button_clean_temp.add_click({write-tofile-conf Button_clean_temp;Clean-temp})

$GroupBox_R4C.Location = New-Object Drawing.Point 10,65
$GroupBox_R4C.Size = New-Object Drawing.Size 410,140
$GroupBox_R4C.text = "Report 4 Checklist"

$Button_RunReport.Location = New-Object Drawing.Point 5,15
$Button_RunReport.Size = New-Object Drawing.Size 120,30
$Button_RunReport.text = "Run R4C"
$Button_RunReport.add_click({write-tofile-conf Button_RunReport;Run-Reporting})

$Button_ViewReport.Location = New-Object Drawing.Point 5,50
$Button_ViewReport.Size = New-Object Drawing.Size 120,30
$Button_ViewReport.text = "Open R4C"
if(Test-Path $File_R4C){}else{$Button_ViewReport.Enabled = $false}
$Button_ViewReport.add_click({write-tofile-conf Button_ViewReport;View-Reporting})

$Label_Report_summary.Location = New-Object Drawing.Point 5,85
$Label_Report_summary.Enabled = $false
$Label_Report_summary.text = "Stato Report:"

$progressBar_R4C.Location = New-Object Drawing.Point 6,100
$progressBar_R4C.Size = New-Object Drawing.Size 395,30
$progressBar_R4C.Enabled = $false
$progressBar_R4C.Value = 0
$progressBar_R4C.Style="Continuous"

$GroupBox_R4C_controls.Location = New-Object Drawing.Point 130,10
$GroupBox_R4C_controls.Size = New-Object Drawing.Size 270,80
$GroupBox_R4C_controls.text = "Controlli"

$Label_Report_system.Location = New-Object Drawing.Point 5,15
$Label_Report_system.Size = New-Object Drawing.Size 125,20
$Label_Report_system.Enabled = $false
$Label_Report_system.text = "Sistema: "

$Label_Report_network.Location = New-Object Drawing.Point 5,35
$Label_Report_network.Size = New-Object Drawing.Size 125,20
$Label_Report_network.Enabled = $false
$Label_Report_network.text = "Network: "

$Label_Report_services.Location = New-Object Drawing.Point 5,55
$Label_Report_services.Size = New-Object Drawing.Size 125,20
$Label_Report_services.Enabled = $false
$Label_Report_services.text = "Servizi: "

$Label_Report_SCCM.Location = New-Object Drawing.Point 135,15
$Label_Report_SCCM.Size = New-Object Drawing.Size 125,20
$Label_Report_SCCM.Enabled = $false
$Label_Report_SCCM.text = "SCCM: "

$Label_Report_McAfee.Location = New-Object Drawing.Point 135,35
$Label_Report_McAfee.Size = New-Object Drawing.Size 125,20
$Label_Report_McAfee.Enabled = $false
$Label_Report_McAfee.text = "McAfee: "

$Label_Report_agenthp.Location = New-Object Drawing.Point 135,55
$Label_Report_agenthp.Size = New-Object Drawing.Size 125,20
$Label_Report_agenthp.Enabled = $false
$Label_Report_agenthp.text = "Agent HP: "

########################################################################################
###################################ContentTabPageAbout##################################
########################################################################################

$Label_about.Location = New-Object Drawing.Point 70,10
$Label_about.Size = New-Object Drawing.Size 400,75
$Label_about.TextAlign = "TopCenter"
$Label_about.text = 
"winPlementator $version_winplementator_full
By Andrea Giardoni - rev.1.9 (JUN/2021)"


########################################################################################
#################################Add all objects to form################################
########################################################################################

########################################################################################
#################################AddContentTabPageSecurity##############################
########################################################################################

$GroupBox_hardening.Controls.Add($Button_apply_hardening)
#$GroupBox_hardening.Controls.Add($Button_iiscrypto)
$TabPageSecurity.Controls.Add($GroupBox_hardening)
$TabPageSecurity.Controls.Add($Label_hard)
$TabPageSecurity.Controls.Add($Button_iiscrypto)
$TabPageSecurity.Controls.Add($Label_iiscrypto)

########################################################################################
#################################AddContentTabPageSystem################################
########################################################################################

$GroupBox_VmW.Controls.Add($TextBox_hostname)
$GroupBox_VmW.Controls.Add($Button_changehn)
$GroupBox_VmW.Controls.Add($Button_regional_custom)
$GroupBox_VmW.Controls.Add($Button_resize_disk)
$GroupBox_VmW.Controls.Add($Button_admin_changes)
$GroupBox_domain.Controls.Add($TextBox_username)
$GroupBox_domain.Controls.Add($TextBox_password)
$GroupBox_domain.Controls.Add($DropDown_domains)
$GroupBox_domain.Controls.Add($Button_joindomain)
$GroupBox_domain.Controls.Add($Button_groups_and_user_add)
$GroupBox_domain.Controls.Add($Button_admin_home)
$GroupBox_azure.Controls.Add($Button_admin_changes2)
$GroupBox_azure.Controls.Add($Button_admin_home2)
$GroupBox_azure.Controls.Add($Button_regional_custom2)
$GroupBox_azure.Controls.Add($Button_groups_and_user_add2)
$TabPageSystem.Controls.Add($TextBox_hostname)
$TabPageSystem.Controls.Add($TextBox_username)
$TabPageSystem.Controls.Add($TextBox_password)
$TabPageSystem.Controls.Add($DropDown_domains)
$TabPageSystem.Controls.Add($Button_changehn)
$TabPageSystem.Controls.Add($Button_joindomain)
$TabPageSystem.Controls.Add($Button_admin_changes)
$TabPageSystem.Controls.Add($Button_admin_home)
$TabPageSystem.Controls.Add($Button_regional_custom)
$TabPageSystem.Controls.Add($Button_groups_and_user_add)
$TabPageSystem.Controls.Add($Button_resize_disk)
##azure##
$TabPageSystem.Controls.Add($Button_admin_changes2)
$TabPageSystem.Controls.Add($Button_admin_home2)
$TabPageSystem.Controls.Add($Button_regional_custom2)
$TabPageSystem.Controls.Add($Button_groups_and_user_add2)
$TabPageSystem.Controls.Add($GroupBox_VmW)
$TabPageSystem.Controls.Add($GroupBox_domain)
$TabPageSystem.Controls.Add($GroupBox_azure)
$GroupBox_VmW.Controls.Add($GroupBox_domain)

########################################################################################
################################AddContentTabPageNetwork################################
########################################################################################
$TabPageNetwork.Controls.Add($Button_refresh_list_nic)
$TabPageNetwork.Controls.Add($Label_currentnics)
$TabPageNetwork.Controls.Add($DropDown_listnics)
$TabPageNetwork.Controls.Add($Button_disable_ipv6)
$TabPageNetwork.Controls.Add($Button_change_name_nic)
$GroupBox_set_ipaddr.Controls.Add($Label_ipaddr)
$GroupBox_set_ipaddr.Controls.Add($TextBox_ipaddr1)
$GroupBox_set_ipaddr.Controls.Add($TextBox_ipaddr2)
$GroupBox_set_ipaddr.Controls.Add($TextBox_ipaddr3)
$GroupBox_set_ipaddr.Controls.Add($TextBox_ipaddr4)
$GroupBox_set_ipaddr.Controls.Add($Label_Netmask)
$GroupBox_set_ipaddr.Controls.Add($DropDown_netmask)
$GroupBox_set_ipaddr.Controls.Add($Label_gw)
$GroupBox_set_ipaddr.Controls.Add($TextBox_gw1)
$GroupBox_set_ipaddr.Controls.Add($TextBox_gw2)
$GroupBox_set_ipaddr.Controls.Add($TextBox_gw3)
$GroupBox_set_ipaddr.Controls.Add($TextBox_gw4)
$GroupBox_set_ipaddr.Controls.Add($Button_setipaddr)
$GroupBox_set_ipaddr.Controls.Add($Button_setdhcp)
$TabPageNetwork.Controls.Add($GroupBox_set_ipaddr)
$TabPageNetwork.Controls.Add($Label_modifiednamenic)
$TabPageNetwork.Controls.Add($DropDown_modifiednamenic)
$TabPageNetwork.Controls.Add($Button_binding_nic)
$TabPageNetwork.Controls.Add($Button_reset_nonpresent_nic)
$TabPageNetwork.Controls.Add($Label_notice_dns)
$TabPageNetwork.Controls.Add($GroupBox_dns)
$GroupBox_dns.Controls.Add($Button_dns_prod_nord)
$GroupBox_dns.Controls.Add($Button_dns_prod_center)
$GroupBox_dns.Controls.Add($Button_dns_prod_south)
$GroupBox_dns.Controls.Add($Button_dns_cert)
$GroupBox_dns.Controls.Add($Button_dns_svil)
$GroupBox_dns.Controls.Add($Button_dns_mgmt)
########################################################################################
###############################AddContentTabPageServices################################
########################################################################################
$GroupBox_services.Controls.Add($Button_firewall_disable)
$GroupBox_services.Controls.Add($Button_rdp_enable)
#$GroupBox_services.Controls.Add($Button_remove_SCCM)
#$GroupBox_features.Controls.Add($Button_npas_enable)
#$GroupBox_features.Controls.Add($Button_iis_install)
#$GroupBox_features.Controls.Add($Button_failover_install)
#$GroupBox_features.Controls.Add($GroupBox_snmp)
#$GroupBox_features.Controls.Add($Button_dotnet35_install)
#$GroupBox_snmp.Controls.Add($Button_snmp_install)
#$GroupBox_snmp.Controls.Add($Button_snmp_configure)
#$GroupBox_snmp.Controls.Add($Button_snmp_remove)
#$GroupBox_act.Controls.Add($Button_act_kms)
#$GroupBox_act.Controls.Add($Button_act_mak)
#$GroupBox_act.Controls.Add($TextBox_key)
$GroupBox_evf.Controls.Add($Button_evf_to1)
$GroupBox_evf.Controls.Add($Button_evf_to2)
$GroupBox_evf.Controls.Add($Button_evf_po)
$GroupBox_evf.Controls.Add($Button_evf_ro)
$GroupBox_evf.Controls.Add($Button_evf_co)
$GroupBox_evf.Controls.Add($Label_to1)
$GroupBox_evf.Controls.Add($Label_to2)
$TabPageServices.Controls.Add($GroupBox_services)
#$TabPageServices.Controls.Add($GroupBox_features)
#$TabPageServices.Controls.Add($GroupBox_act)
$TabPageServices.Controls.Add($GroupBox_evf)

########################################################################################
################################AddContentTabMcAfee#####################################
########################################################################################
$GroupBox_agent_McAfee.Controls.Add($Button_agent_McAfee_svil)
$GroupBox_agent_McAfee.Controls.Add($Button_agent_McAfee_cert)
$GroupBox_agent_McAfee.Controls.Add($Button_agent_McAfee_prod)
$GroupBox_McAfee.Controls.Add($GroupBox_agent_McAfee)
$GroupBox_McAfee.Controls.Add($Button_engine_McAfee)
$GroupBox_McAfee.Controls.Add($Button_engine_McAfee_svil)
$TabPageMcAfee.Controls.Add($GroupBox_McAfee)

########################################################################################
################################AddContentTabPageAgentHP################################
########################################################################################
<#$TabPageAgentHP.Controls.Add($DropDown_listip)
$TabPageAgentHP.Controls.Add($Button_configure_hostsfile)
$TabPageAgentHP.Controls.Add($Label_selectip_agenthp)
$TabPageAgentHP.Controls.Add($Button_agenthp_install)
$GroupBox_agenthp_configure.Controls.Add($Button_agenthp_configure)
$GroupBox_agenthp_configure.Controls.Add($Label_agenthp_configure_progressbar)
$GroupBox_agenthp_configure.Controls.Add($progressBar_agenthp_configure)
$TabPageAgentHP.Controls.Add($GroupBox_agenthp_configure)
$GroupBox_agenthp_verify.Controls.Add($Button_agenthp_verify)
$GroupBox_agenthp_verify.Controls.Add($RichTextBox_agenthp_verify)
$TabPageAgentHP.Controls.Add($GroupBox_agenthp_verify)#>

########################################################################################
################################AddContentTabZabbix#####################################
########################################################################################
$GroupBox_zabbix.Controls.Add($Button_zabbix_prod_install)
$GroupBox_zabbix.Controls.Add($Button_zabbix_cert_install)
$TabPageZabbix.Controls.Add($GroupBox_zabbix)

########################################################################################
################################AddContentTabPageAgentDD################################
########################################################################################
#$TabPageAgentDD.Controls.Add($DropDown_listip)
$TabPageAgentDD.Controls.Add($Button_configure_proxyprod)
$TabPageAgentDD.Controls.Add($Button_configure_proxycert)
$TabPageAgentDD.Controls.Add($Button_AgentDD_install)
$TabPageAgentDD.Controls.Add($Button_checkproxycert)
$TabPageAgentDD.Controls.Add($Button_checkproxyprod)
$TabPageAgentDD.Controls.Add($Button_restart_AgentDD)
$TabPageAgentDD.Controls.Add($Button_DDgui)
$TabPageAgentDD.Controls.Add($Button_removeDD)

$TabPageAgentDD.Controls.Add($GroupBox_AgentDD_TAG)

$TabPageAgentDD.Controls.Add($TextBox_Service)

$TabPageAgentDD.Controls.Add($Label_TAG_Service)
$TabPageAgentDD.Controls.Add($Label_TAG_ENV)
$TabPageAgentDD.Controls.Add($Label_TAG_Site)
$TabPageAgentDD.Controls.Add($Label_TAG_info)
$TabPageAgentDD.Controls.Add($Label_TAG_Type)
$TabPageAgentDD.Controls.Add($Label_TAG_Availability)
$TabPageAgentDD.Controls.Add($Label_TAG_Role)

$TabPageAgentDD.Controls.Add($DropDown_EnvTAG)
$TabPageAgentDD.Controls.Add($DropDown_SiteTAG)
$TabPageAgentDD.Controls.Add($DropDown_TypeTAG)
$TabPageAgentDD.Controls.Add($DropDown_AvailabilityTAG)
$TabPageAgentDD.Controls.Add($DropDown_RoleTAG)

$GroupBox_AgentDD_TAG.Controls.Add($Label_TAG_Service)
$GroupBox_AgentDD_TAG.Controls.Add($Label_TAG_ENV)
$GroupBox_AgentDD_TAG.Controls.Add($Label_TAG_Site)
$GroupBox_AgentDD_TAG.Controls.Add($Label_TAG_Type)
$GroupBox_AgentDD_TAG.Controls.Add($Label_TAG_Availability)
$GroupBox_AgentDD_TAG.Controls.Add($Label_TAG_Role)
$GroupBox_AgentDD_TAG.Controls.Add($Label_TAG_info)

$GroupBox_AgentDD_TAG.Controls.Add($TextBox_Service)

$GroupBox_AgentDD_TAG.Controls.Add($Button_AgentDD_install)
$GroupBox_AgentDD_TAG.Controls.Add($Button_DDgui)
$GroupBox_AgentDD_TAG.Controls.Add($Button_removeDD)

$GroupBox_AgentDD_TAG.Controls.Add($DropDown_EnvTAG)
$GroupBox_AgentDD_TAG.Controls.Add($DropDown_SiteTAG)
$GroupBox_AgentDD_TAG.Controls.Add($DropDown_TypeTAG)
$GroupBox_AgentDD_TAG.Controls.Add($DropDown_AvailabilityTAG)
$GroupBox_AgentDD_TAG.Controls.Add($DropDown_RoleTAG)

########################################################################################
##############################AddContentTabPageReporting################################
########################################################################################
$TabPageReporting.Controls.Add($GroupBox_temp_dir)
$GroupBox_temp_dir.Controls.Add($Button_clean_temp)
$GroupBox_temp_dir.Controls.Add($Button_open_temp)
$TabPageReporting.Controls.Add($GroupBox_R4C)
$GroupBox_R4C.Controls.Add($Button_RunReport)
$GroupBox_R4C.Controls.Add($Button_ViewReport)
$GroupBox_R4C.Controls.Add($progressBar_R4C)
$GroupBox_R4C.Controls.Add($GroupBox_R4C_controls)
$GroupBox_R4C.Controls.Add($Label_Report_summary)
$GroupBox_R4C_controls.Controls.Add($Label_Report_system)
$GroupBox_R4C_controls.Controls.Add($Label_Report_network)
$GroupBox_R4C_controls.Controls.Add($Label_Report_SCCM)
$GroupBox_R4C_controls.Controls.Add($Label_Report_services)
$GroupBox_R4C_controls.Controls.Add($Label_Report_agenthp)
$GroupBox_R4C_controls.Controls.Add($Label_Report_McAfee)

########################################################################################
#################################AddContentTabPageAbout#################################
########################################################################################
$TabPageAbout.Controls.Add($Label_about)
if((Get-Date).Month -eq "4" -and (Get-Date).Day -lt "8"){
$Button_unused.Location = New-Object Drawing.Point 10,85
$Button_unused.Size = New-Object Drawing.Size 400,150
$Button_unused.text = "Bottone SPAZIALE"
$Button_unused.ForeColor = "Yellow"
$Button_unused.BackColor = "Black"
$Button_unused.Font = New-Object Drawing.Font("Gill Sans MT",32,[System.Drawing.FontStyle]::Bold)
$Button_unused.add_click({write-tofile-conf Button_unused;[Console]::Beep(440,500);[Console]::Beep(440,500) ;[Console]::Beep(440,500)
[Console]::Beep(349,350);[Console]::Beep(523,150) ;[Console]::Beep(440,500) ;[Console]::Beep(349,350)
[Console]::Beep(523,150);[Console]::Beep(440,1000);[Console]::Beep(659,500) ;[Console]::Beep(659,500)
[Console]::Beep(659,500);[Console]::Beep(698,350) ;[Console]::Beep(523,150) ;[Console]::Beep(415,500)
[Console]::Beep(349,350);[Console]::Beep(523,150) ;[Console]::Beep(440,1000);[Console]::Beep(880,500)
[Console]::Beep(440,350);[Console]::Beep(440,150) ;[Console]::Beep(880,500) ;[Console]::Beep(830,250)
[Console]::Beep(784,250);[Console]::Beep(740,125) ;[Console]::Beep(698,125) ;[Console]::Beep(740,250)
[Console]::Beep(455,250);[Console]::Beep(622,500) ;[Console]::Beep(587,250) ;[Console]::Beep(554,250)
[Console]::Beep(523,125);[Console]::Beep(466,125) ;[Console]::Beep(523,250) ;[Console]::Beep(349,125)
[Console]::Beep(415,500);[Console]::Beep(349,375) ;[Console]::Beep(440,125) ;[Console]::Beep(523,500)
[Console]::Beep(440,375);[Console]::Beep(523,125) ;[Console]::Beep(659,1000);[Console]::Beep(880,500)
[Console]::Beep(440,350);[Console]::Beep(440,150) ;[Console]::Beep(880,500) ;[Console]::Beep(830,250)
[Console]::Beep(784,250);[Console]::Beep(740,125) ;[Console]::Beep(698,125) ;[Console]::Beep(740,250)
[Console]::Beep(455,250);[Console]::Beep(622,500) ;[Console]::Beep(587,250) ;[Console]::Beep(554,250)
[Console]::Beep(523,125);[Console]::Beep(466,125) ;[Console]::Beep(523,250) ;[Console]::Beep(349,250)
[Console]::Beep(415,500);[Console]::Beep(349,375) ;[Console]::Beep(523,125) ;[Console]::Beep(440,500)
[Console]::Beep(349,375);[Console]::Beep(261,125) ;[Console]::Beep(440,1000)})
$TabPageAbout.Controls.Add($Button_unused)}

########################################################################################
#################################AddTabsInToTabControl##################################
########################################################################################

$tabControl.Controls.Add($TabPageSecurity)
$tabControl.Controls.Add($TabPageSystem)
$tabControl.Controls.Add($TabPageNetwork)
$tabControl.Controls.Add($TabPageServices)
#$tabControl.Controls.Add($TabPageAgentHP)
$tabControl.Controls.Add($TabPageZabbix)
#$tabControl.Controls.Add($TabPageAgentDD)
$tabControl.Controls.Add($TabPageMcAfee)
$tabControl.Controls.Add($TabPageReporting)
$tabControl.Controls.Add($TabPageAbout)

########################################################################################
#################################AddTabControlInToFrom##################################
########################################################################################
get-listdomains
cls
get-listip
cls
get-listnetmask
cls
get-listnics
cls
get-listmodifiednamenic
cls
get-EnvTag
cls
get-SiteTag
cls
get-TypeTag
cls
get-AvailabilityTAG
cls
get-RoleTAG
cls
selection-fromdomain
cls
Write-Log "Apertura Winplementator da utente $env:USERNAME"
$Form.Controls.Add($tabControl)
$Form.controls.add($Button_close)
$Form.controls.add($Button_reset_conf)
$Form.controls.add($Button_restart)
$Form.controls.add($Button_logout)
$Form.ShowDialog()
