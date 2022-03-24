$steamcmd_url = 'https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip';
$metamod_url = 'https://mms.alliedmods.net/mmsdrop/1.12/mmsource-1.12.0-git1157-windows.zip';
$sourcemod_url = 'https://sm.alliedmods.net/smdrop/1.11/sourcemod-1.11.0-git6863-windows.zip';
$practice_mode_url = 'https://github.com/splewis/csgo-practice-mode/releases/download/1.3.4/practicemode_1.3.4.zip';
$location = (Get-Item .).FullName;
$steamcmd_zip = (Get-Item .).FullName + '/downloads/steamcmd.zip';
$metamod_zip = (Get-Item .).FullName + '/downloads/mmsource-1.12.0-git1157-windows.zip';
$sourcemod_zip = (Get-Item .).FullName + '/downloads/sourcemod-1.11.0-git6863-windows.zip';
$practice_mode_zip = (Get-Item .).FullName + '/downloads/practicemode_1.3.4.zip'; 

Add-Type -AssemblyName System.IO.Compression.FileSystem
function Unzip
{
    param([string]$zipfile, [string]$outpath)

    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
}

if (!(Test-Path $location'/downloads')) {
    Write-Host 'Creating downloads folder';
    New-Item $location'/downloads' -itemType Directory;
}

if (!(Test-Path $location'/steamcmd')) {
    Write-Host 'Downloading steamcmd...';
    Invoke-WebRequest $steamcmd_url -OutFile $steamcmd_zip;
    Unzip $steamcmd_zip $location'/steamcmd';
}

if (!(Test-Path $location'/game/csgo')) {
    Write-Host 'Creating game/csgo directory';
    New-Item $location'/game/csgo' -itemType Directory;
}

if (!(Test-Path $location'/game/csgo/addons')) {
    Write-Host 'Downloading Metamod, Sourcemod and Practice Mode';
    Invoke-WebRequest $metamod_url -OutFile $metamod_zip;
    Invoke-WebRequest $sourcemod_url -OutFile $sourcemod_zip;
    Invoke-WebRequest $practice_mode_url -OutFile $practice_mode_zip;
    Unzip $metamod_zip $location'/game/csgo';
    Unzip $sourcemod_zip $location'/game/csgo';
    Unzip $practice_mode_zip $location'/game/csgo';
    
    Write-Host 'Ignore error for `sm_warmode_off.cfg` and a `LICENSE` file.';
    Write-Host 'Removing Admin from Practice Mode';
    $file = $location + '/game/csgo/addons/sourcemod/configs/admin_overrides.cfg';
    $find = '}';
    $replace = '	"sm_prac"	""
}';
    (Get-Content $file).replace($find, $replace) | Set-Content $file;
}

function New-SymLink ($link, $target, [bool]$folder = 0)
{
    if ($folder -eq 1) {
        $command = "cmd /c mklink /d"
    } else {
        $command = "cmd /c mklink"
    }
    invoke-expression "$command ""$link"" ""$target"""
}

if (!(Test-Path $location'/game/csgo/maps')) {
    DO
    {
    $confirmation = Read-Host 'Do you have want to save space by creating a symbolic link to your CSGO files/folders? It can help by saving around ~27GB of space. [y/n]'
    if ($confirmation -eq 'y') {
        if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
            Write-Host 'Start script with Admin rights';
            pause
            EXIT
        }
        $csgo_location = Read-Host -Prompt "What's your CSGO folder location? (ex: C:\Program Files (x86)\Steam\steamapps\common\Counter-Strike Global Offensive)";
        Write-Host "Creating symbolic links";

        New-SymLink -link $location'\game\csgo\maps' -target $csgo_location'\csgo\maps' -folder 1;

        $files = Get-ChildItem $csgo_location'/csgo'
        foreach ($f in $files){
            if ($f -like "*.vpk") {
                New-SymLink -link $location'\game\csgo\'$f -target $f.FullName -folder 0;
            }
        }

        Write-Host "Created symbolic link";
    }
    } While (($confirmation -ne 'y') -and ($confirmation -ne 'n'));


}

Write-Host 'Starting update.bat';
Start-Process -Wait "update.bat";

Write-Host 'Starting server...';
Start-Process "run-server.bat";