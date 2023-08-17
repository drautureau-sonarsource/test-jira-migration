# Requirements:
# - C:\VS2015Installer\SonarVS2015AdminDeployment.xml already existing on the image
# - D volume available to mount

$env:VS2015_INSTALLER_DIR = "C:\VS2015Installer"
$env:VS2015_ISO_URL = "https://go.microsoft.com/fwlink/?LinkId=615448&clcid=0x409"
$env:VS2015_ISO_NAME = "VS2015.iso"

Set-Location $env:VS2015_INSTALLER_DIR

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
(New-Object System.Net.WebClient).DownloadFile($env:VS2015_ISO_URL, $env:VS2015_ISO_NAME)

$isoPath = Join-Path $env:VS2015_INSTALLER_DIR $env:VS2015_ISO_NAME
Mount-DiskImage -ImagePath $isoPath # We assumes the image is mounted onto D

$sonarAdminDeploymentXmlPath = Join-Path $env:VS2015_INSTALLER_DIR "SonarVS2015AdminDeployment.xml"
$logsPath = Join-Path $env:VS2015_INSTALLER_DIR "Logs.log"
& "D:\vs_community.exe" /AdminFile $sonarAdminDeploymentXmlPath /Log $logsPath /Quiet

# The installation is asynchronous: the caller of this script needs to wait until the following line is written to Logs.log:
#   [0AD8:63E8][2023-05-04T14:05:23]i007: Exit code: 0x0, restarting: No
#
# The exit codes signalling a successful installation are:
#   $validExitCodes = @(
#         0, # success
#         3010, # success, restart required
#         2147781575 # pending restart required
#   )
