
# Get the latest version 

Invoke-WebRequest https://git.io/vrZWB -Outfile dbatools.zip

if (Test-Path -Path ".\dbatools-master")
{
    Remove-Item -Path .\dbatools-master -force -recurse
}

if (Test-Path -Path ".\contents")
{
    Remove-Item -Path .\contents -Force -Recurse
}


New-Item -Path .\contents -ItemType Directory 
Expand-Archive dbatools.zip -DestinationPath .
Move-Item -Path .\dbatools-master\* -Destination .\contents

if (Test-Path -Path ".\dbatools-master")
{
    Remove-Item -Path .\dbatools-master -force -recurse
}


if (Test-Path -Path .\dbatools.zip)
{
    Remove-Item -Path .\dbatools.zip
    Remove-Item -Path .\contents\install.ps1
}


if (Test-Path -Path ".\contents")
{
    #Set-Location -Path .\contents
    & nuget spec  | Out-Null
    if (Test-Path -Path .\Package.nuspec)
    {

        $latestRelease = Invoke-WebRequest https://github.com/sqlcollaborative/dbatools/releases/latest -Headers @{"Accept"="application/json"} -UseBasicParsing
        $latestRelease.Content -match '.*"tag_name":"(.*)".*' | Out-Null
        $latestVersion = [String]$Matches[1]

        $spec_file = [xml](Get-Content -Path .\Package.nuspec)

        $spec_file.package.metadata.id = "dbatools"
        $spec_file.package.metadata.version = $latestVersion.replace("v","")
        $spec_file.package.metadata.authors = "Simon Rollinson"
        $spec_file.package.metadata.owners = "Simon Rollinson"
        $spec_file.package.metadata.licenseUrl = "https://github.com/sqlcollaborative/dbatools/blob/master/LICENSE.txt"
        $spec_file.package.metadata.projectUrl = "http://dbatools.io"
        $spec_file.package.metadata.iconUrl = "https://camo.githubusercontent.com/8c93ea16603184bd5a75fe4da5647891e23ed8e1/68747470733a2f2f626c6f672e6e65746e657264732e6e65742f77702d636f6e74656e742f75706c6f6164732f323031362f30352f646261746f6f6c732e706e67"
        $spec_file.package.metadata.description = "Powershell module of useful SQL Server functions"
        $spec_file.package.metadata.tags = "dbatools powershell"

        $node = $spec_file.package.metadata.dependencies.dependency
        $node.ParentNode.RemoveChild($node)

        $working_dir = $PWD
        $spec_file.Save("$working_dir\dbatools.nuspec")

        # Get rid of the installer we don't need that
        Remove-Item -Path Package.nuspec -Force
        Remove-Item -Path Readme.md -Force

        & nuget pack | Out-Null

        & nuget push *.nupkg -ApiKey API-IHP1C4UP9XPENG20TN0BTZHJZK4 -Source "http://192.168.0.6/nuget/packages"

    }
}


#Import-Module .\dbatools-master\dbatools.psd1