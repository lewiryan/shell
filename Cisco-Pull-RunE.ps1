#-----------------------------------------------------------------------------------------------------------------------------------
# PowerShell Script for Connecting using SSH to Network Devices and to issue one or multiple commands. 
# RECOMMENDED USE: Automating Backups 
# ATTENTION: Module SSH-Sessions must be in the Default System32 Location: Windows\system32\WindowsPowerShell\v1.0\Modules
# MORE INFORMATION: http://www.powershelladmin.com/wiki/SSH_from_PowerShell_using_the_SSH.NET_library
#-----------------------------------------------------------------------------------------------------------------------------------
# Settings below should not need to be changed, however feel free to add-on!
# Lets run by some house rules like asking what to do if an error occurs.
$ErrorActionPreference ="Inquire"
# Do you even have the SSH-Sessions Module? Let’s check before we continue.
Import-Module SSH-Sessions
# With the output file that is created by this script lets timestamp
# the current Year, Month and Day and put it as part of the filename.
$time ="$(get-date -f yyyy-MM-dd)"
# Let's put in something in front of the date timestamp of the soon to be 
# created file defualt is "config"
$filename ="config"
# By default the type of file created is a text file.
$ext =".txt"
#-----------------------------------------------------------------------------------------------------------------------------------
# START WITH CUSTOM CONFIGURATION

# Where do you want the created file to be placed? The current user running this script will need
# access to that location. Also this script will not create folders if the path does not exist expect an error
# A good example to place the created files would be "C:\Cisco-Backups"
$filepath =""


# Depending on the amount of devices you want to connect, this part of the script could be lengthy.
# To set this up follow the example.
#	$d1 ="192.168.1.1" 
# This is setting up a variable called "d1" followed by the IP address of the device you would connect with SSH.
# Each device will have a different variable if you have five devices it would look like the following:
#	$d2 ="192.168.2.1
#	$d3 ="192.168.3.1
#	$d4 ="192.168.4.1
#	$d5 ="192.168.5.1
#	$d6 ="192.168.6.1 

# Below is your custom list of devices that you want to connect with SSH.
$d1 =""


# Depending on the environment each device may have a different account to log in.
# For simplicity's sake it is recommended to use one custom account for all logins.
# However you can specify different account logins per device. Follow the example.
#	$u1 ="admin"
# 	$u2 ="bob"
# This example shows two different username accounts it recommended to match these up with
# the device you would be connecting to, for example "d1" uses "u1", etc.

# Below is your custom list of login account names that each device will use, if all devices
# use the same account just specify one variable.
$u1 =""


# Depending on the environment each device may have a different password to log in.
# For simplicity's sake it is recommended to use one password for all logins.
# However you can specify different passwords per device. Follow the example.
#	$p1 ="password123"
# 	$p2 ="P@$$w0rd987"
# This example shows two different passwords it recommended to match these up with
# the device and username you would be connecting to, for example "d1" uses "u1" which use "p1" etc.

# Below is your custom list of passwords that each device will use, if all devices use the same 
# password just specify one variable.
$p1 =""


# Depending on the amount of devices you want to connect, this part of the script could be lengthy.
# The command to connect with SSH is "New-SshSession" We have to specify the device to connect, the username
# to use along with the password. Follow the example.
#	New-SshSession $d1 -Username $u1 -Password "$p1"
#	New-SshSession $d2 -Username $u2 -Password "$p2"
# This example shows that we are going to be connecting with two devices, with two different usernames and passwords.

# If you are using the same username and password on all devices it would follow this example which is using the same
# variable for the username and password.
#	New-SshSession $d1 -Username $u1 -Password "$p1"
#	New-SshSession $d2 -Username $u1 -Password "$p1"

# Below is your custom list that specifies the device to connect to, the username and password.
# If all devices use the same username and password just speifiy the same variable.
New-SshSession $d1 -Username $u1 -Password "$p1"


# DONE WITH CUSTOM CONFIGURATION
#-----------------------------------------------------------------------------------------------------------------------------------

# What command to you want to run on all devices defualt is the 'show run' command.
$c1 ="show run"

# Lets run the command that we configured and output all of that into one file.
$Results = Invoke-Sshcommand -InvokeOnAll -Command "$c1" | Out-File "$filepath$filename-$time$ext"

# We are done running commands on these devices lets close the connection.
Remove-SshSession -RemoveAll

# Close out of PowerShell
exit
