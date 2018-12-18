# Barracuda Load Balancer Powershell Script
# Minimum version of Powershell is 6.0.4 - Can download stable releases @ https://github.com/PowerShell/PowerShell
# Puts servers in Maintenance, Disable or Enable status
# Put the URL API of the LB (example: "https://192.168.1.5/restapi/v2")
$uri = ""
# Put the group name, usually its "default" unless you have something different
$groupname = "default"
# Put the service name you would like to modify, you can find this in the LB going to BASIC->Services
$servicename = ""
# Put the server you would like to modify, you can find the names of the servers under BASIC->Services
# You can add additional servers to this list if you want to modify multiple servers at once, add additional variables
$realserver1 = ""
$realserver2 = ""
# What status would you change the servers in the LB to? Valid values are enable, disable, or maintenance. Values are lower-case sensitive
$status = "enable"
# Login into Barracuda you will get a prompt to login, currently only local accounts work for API. 
$credential = Get-Credential -Message "Please type a username and password to login into the Barracuda LB"
$password = $credential.GetNetworkCredential().password
$username = $credential.GetNetworkCredential().username
# POST Request to Login into Barracuda
$authUrl_Body = @{
    password = $password
    username = $username
}
# Convert this request into JSON and call it $jsonurlbody
$jsonauth_Body = $authUrl_Body | ConvertTo-Json
#Grab the token to and keep note of it, and use to login into Barracuda from now on
$auth = Invoke-RestMethod -Uri "$uri/login" -ContentType "application/json" -Method POST -Body $jsonauth_Body -SkipCertificateCheck
$authtoken = $auth.token
# Barracuda only supports username only no password required when we have the token put this into a PSCredential to null the password
$lbcred = New-Object System.Management.Automation.PSCredential ("$authtoken", (new-object System.Security.SecureString))
# POST Request to put a server into Maintenance, Enable, or Disable
$statusURL_Body = @{
    status = $status
}
# Convert this request into JSON and call it $jsonstatus_Body
$jsonstatus_Body = $statusURL_Body | ConvertTo-Json
# Put $realserver1 into $status "status"
Invoke-RestMethod -Uri "$uri/virtual_service_groups/$groupname/virtual_services/$servicename/servers/$realserver1" -Credential $lbcred -Authentication Basic -ContentType "application/json" -Method PUT -Body $jsonstatus_Body -SkipCertificateCheck | ConvertTo-Json
# Put $realserver2 into $status "status"
Invoke-RestMethod -Uri "$uri/virtual_service_groups/$groupname/virtual_services/$servicename/servers/$realserver2" -Credential $lbcred -Authentication Basic -ContentType "application/json" -Method PUT -Body $jsonstatus_Body -SkipCertificateCheck | ConvertTo-Json
# If you have additional servers copy the command above and replace it with a different variable

# Invoke-RestMethod -Uri "$uri/virtual_service_groups/$groupname/virtual_services/$servicename/" -Authentication Basic -Credential $lbcred -ContentType "application/json" -Method GET -SkipCertificateCheck | ConvertTo-Json
