[CmdletBinding()]
param (
    [Parameter()]
    [Switch]
    $DebugExport,
    [Switch]
    $NoVersionIncrement
)

$project_name_key = "config/name"
$project_version_key = "config/version"

$config = ([xml](Get-Content '.\build_config.xml')).config

$exports = $config.exports
# Currently a workaround, this should be more dynamic (dictionary?)
$export_name_web = "Web"
$export_file_name_web = "index"
$export_name_exe = "Windows Desktop"

$version_prefix = $config.version_prefix

$git_main_branch = $config.git_main_branch

$exports_base_dir = $config.exports_base_dir

if (!(Test-Path -PathType Leaf .\project.godot))
{
    Write-Error "Couldn't find project.godot: must be run from project root"
    exit 1;
}

function FindProjectSetting
{
    param ( [string] $key )

    $groups = (Select-String -Path .\project.godot -Pattern "$key=""(.*)""").Matches.Groups

    if ($groups){
        return $groups[1].Value
    }
    else
    {
        return $null
    }
}

# Get the project name from project.godot
$project_name_groups = (Select-String -Path .\project.godot -Pattern "$project_name_key=""(.*)""").Matches.Groups

if ($project_name_groups)
{
    $project_name = $project_name_groups[1].Value
}
else
{
    Write-Error "Invalid project.godot: missing or empty project name ($project_name_key)"
    exit 1;
}

# Get the version from project.godot
# Note that this must end with a number, which is what will be considered the build number
$version_groups = (Select-String -Path .\project.godot -Pattern "$project_version_key=""((.*)([0-9]+))""").Matches.Groups

$project_version = FindProjectSetting $project_version_key
$version_string = "$version_prefix$project_version"

if ($version_groups)
{
    # Set the version string
    $project_version = $version_groups[1].Value
    $version_string = "$version_prefix$project_version"

    # If on non-main branch, append the commit number
    if ((git rev-parse --abbrev-ref HEAD) -ne $git_main_branch)
    {
        $commit = (git rev-parse --short HEAD)

        $version_string = "$version_string $commit"
    }
    else
    {
        # Update the version if on main branch
        $rev_number = $version_groups[3].Value
        $rest = $version_groups[2].Value

        $new_rev_number = [int]$rev_number+1

        $new_version = "$rest$new_rev_number"

        Write-Host "Updating project version ($project_version_key) from $rest$rev_number to $new_version"

        (Get-Content .\project.godot) `
            -replace "$project_version_key="".*""", "$project_version_key=""$new_version""" |
            Out-File .\project.godot -Encoding ASCII
    }
}
else
{
    Write-Host "Couldn't find project version ($project_version_key), ommitting from export path"
    $version_string = ""
}

$export_versioned_dir = "$exports_base_dir\$project_name$version_string"

New-Item -Path $export_versioned_dir -ItemType Directory

foreach ($match in (Select-String -Path .\export_presets.cfg -Pattern "name=""(.*)""").Matches)
{
    $export_name = $match.Groups[1].Value

    if ("" -eq $export_name)
    {
        continue
    }

    $export_file_name = "$project_name$version_string - $export_name"

    $export_zip_file = "$export_file_name.zip"

    if ($export_name_web -eq $export_name)
    {
        # Currently a workaround, this should be configurable
        $export_file_name = $export_file_name_web
    }
    elseif ($export_name_exe -eq $export_name)
    {
        # Currently a workaround, this should be configurable
        $export_file_name = "$export_file_name.exe"
    }

    $export_path = "$export_versioned_dir\$export_name"
    $export_file_path = "$export_path\$export_file_name"

    $export_switch = "--export-release"
    if ($DebugExport)
    {
        $export_switch = "--export-debug"
    }

    New-Item -Path "$export_path" -ItemType Directory
    godot --headless $export_switch "$export_name" "$export_file_path"
    
    Compress-Archive "$export_path\*" -DestinationPath "$export_versioned_dir\$export_zip_file"
}