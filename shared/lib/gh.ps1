function gh {
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
      } elseif ($ThirdParty) {
        $Dir = "$GH\3rd-party"
      }
      $Projects = $(Get-ChildItem $Dir | % Name)
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
        Write-Output "External dev directory is not set up."
        return
      }
      $Dir = $GH2
    } else {
      $Dir = $GH
    }
    if ($ThirdParty) {
      $Dir = "$Dir\3rd-party"
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
      cd $Dir
      mkdir $Project
      cd $Project
      git init
    } elseif ($Clone) {
      if (-not ($Project -match "[a-zA-Z0-9\-_]+\/[a-zA-Z0-9\-_]+")) {
        Write-Host "Repo name is invalid."
        return
      }
      cd $Dir
      git clone $Repo $LocalDir
      cd $LocalDir
    } else {
      cd "$Dir\$Project"
    }
  }
}
