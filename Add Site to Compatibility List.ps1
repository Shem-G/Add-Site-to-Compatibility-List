# Set $key to the registry entry
$key = "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft"
 
### Add new paths to registry if neccessary ###
if(-Not (Test-Path "$key\Internet Explorer")) {
New-Item -Path $key -Name "Internet Explorer" | Out-Null
}
 
if(-Not (Test-Path "$key\Internet Explorer\BrowserEmulation")) {
New-Item -Path "$key\Internet Explorer" -Name "BrowserEmulation" | Out-Null
}
 
if(-Not (Test-Path "$key\Internet Explorer\BrowserEmulation\PolicyList")) {
New-Item -Path "$key\Internet Explorer\BrowserEmulation" -Name "PolicyList" | Out-Null
}
###
 
# Use Get-IPrange.ps1 to find necessary domains, apply regex
. .\Get-IPrange.ps1
$cidr = "^((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)\.){3}(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)/(3[0-2]|[1-2]?[0-9])$"

# Add the domains to be added to the compatibility list to the $domains array. Examples: google.com, 192.168.1.0/24
$domains = @("ups.com","153.2.224.50")
 
# This is the place in the registry that we are adding the domains
$regkey = "$key\Internet Explorer\BrowserEmulation\PolicyList"

# Add to the compatibility list and move to the next key in $domains
foreach($domain in $domains) {
if($domain -match $cidr) {
$network = $domain.Split("/")[0]
$subnet = $domain.Split("/")[1]
$ips = Get-IPrange -ip $network -cidr $subnet
$ips | %{$val = New-ItemProperty -Path $regkey -Name $_ -Value $_ -PropertyType String | Out-Null}
$count = $count - 1 + $ips.Length
}
else {
New-ItemProperty -Path $regkey -Name $domain -Value $domain -PropertyType String | Out-Null
}
}