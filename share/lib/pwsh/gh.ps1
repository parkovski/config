function dev {
  [CmdletBinding()]
  param(
    [Alias('t')][switch]$ThirdParty,
    [Alias('n')][switch]$NewProject,
    [Alias('a')][switch]$AltDir,
    [Alias('c')][switch]$Clone
  )
  dynamicparam {
    $Projects = $null
    if ((-not $NewProject) -and (-not $Clone)) {
      $Dir = $GH
      if ($AltDir) {
        $Dir = $GH2
      }
      if ($ThirdParty) {
        $Dir = "$Dir\3p"
      }
      $Projects = $(Get-ChildItem $Dir | ForEach-Object Name)
    }
    $p = New-DynamicParams
    if ($NewProject) {
      $p = Add-DynamicParam -Dict $p Project -Type:([String]) `
             -HelpMessage:"Project Name" -Position:0 -NotNullOrEmpty
    } elseif ($Clone) {
      $p = Add-DynamicParam -Dict $p Project -Type:([String]) `
             -HelpMessage:"Project Name" -Position:0 -NotNullOrEmpty `
         | Add-DynamicParam -Dict $p LocalDir -Type:([String]) `
             -HelpMessage:"Local clone dir" -Position:1
    } else {
      $p = $p | Add-DynamicParam Project -Type:([String]) `
                  -HelpMessage:"Project Name" -Position:0 -NotNullOrEmpty `
                  -Values:$Projects
    }
    $p
  }
  begin {
    if ($AltDir) {
      if (-not $GH2) {
        Write-Output "External dev directory (env GH2) is not set up."
        return
      }
      $Dir = $GH2
    } else {
      $Dir = $GH
    }
    if ($ThirdParty) {
      $Dir = "$Dir\3p"
    }

    $Project = $PSBoundParameters.Project
    if ($Clone) {
      if (($Project -match "^[a-zA-Z0-9-_.]+@[^:]:.+$") `
          -or ($Project -match "^https?://"))
      {
        $Repo = $Project
      } elseif ($Project.StartsWith($ProVar.ghuser + '/')) {
        $Repo = "git@github.com:$Project"
      } else {
        $Repo = "https://github.com/$Project"
      }
      if (-not $LocalDir) {
        $LocalDir = $Project.Substring($Project.LastIndexOf('/') + 1)
      }
    }
  }
  process {
    if ($NewProject) {
      Set-Location $Dir
      mkdir $Project
      Set-Location $Project
      git init
    } elseif ($Clone) {
      if (-not ($Project -match "[a-zA-Z0-9\-_]+\/[a-zA-Z0-9\-_]+")) {
        Write-Host "Repo name is invalid."
        return
      }
      Set-Location $Dir
      git clone $Repo $LocalDir
      Set-Location $LocalDir
    } else {
      Set-Location "$Dir\$Project"
    }
  }
}
