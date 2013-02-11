$psake.use_exit_on_error = $true

#########################################
# to build a new version
# 1. git tag 1.0.x
# 2. build package
#########################################

properties {
    $baseDir = $psake.build_script_dir
    $version = git describe --abbrev=0 --tags
    $changeset = (git log -1 $version --pretty=format:%H)
}

Task default -depends Test
Task Package -depends Test, Version-Module, Package-Nuget, Unversion-Module { }

# run tests
Task Test { & .\PShould.Tests.ps1 }

# package the nuget file
Task Package-Nuget {

    # make sure there is a build directory
    if (Test-Path "$baseDir\build") {
        Remove-Item "$baseDir\build" -Recurse -Force
    }
    mkdir "$baseDir\build"

    # pack it up
    nuget pack "$baseDir\PShould.nuspec" -OutputDirectory "$baseDir\build" -NoPackageAnalysis -version $version
}

# update the version number in the file
Task Version-Module {
    (Get-Content "$baseDir\PShould.psm1") |
      % {$_ -replace '\$version\$', "$version" } |
      % {$_ -replace '\$changeset\$', "$changeset" } |
      Set-Content "$baseDir\PShould.psm1"
}

# clear out the version information in the file
Task Unversion-Module {
    git checkout "$baseDir\PShould.psm1"
}