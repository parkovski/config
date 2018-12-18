chcp 65001 | Out-Null

function Open-PowerShell {
  param([switch]$Admin)
  if ($Admin) {
    Start-Process $PowerShell -Verb Runas
  } else {
    Start-Process $PowerShell
  }
}

function Restore-ConsoleWindow {
  [Console]::SetWindowSize(100, 50)
}

$global:DDev = "D:\dev"
$global:LocalPrograms = "$HOME\AppData\Local\Programs"

# C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\Common7\Tools\VsDevCmd.bat
# C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvars64.bat
$ProVar.vcvars = @{
  Base = "C:\Program Files (x86)\Microsoft Visual Studio";
  Toolsets = @{
    cpp32host32 = "VC\Auxiliary\Build\vcvars32.bat";
    cpp32host64 = "VC\Auxiliary\Build\vcvarsx86_amd64.bat";
    cpp64host32 = "VC\Auxiliary\Build\vcvarsamd64_x86.bat";
    cpp64host64 = "VC\Auxiliary\Build\vcvars64.bat";
    cpparmhost32 = "VC\Auxiliary\Build\vcvarsx86_arm.bat";
    cpparmhost64 = "VC\Auxiliary\Build\vcvarsamd64_arm.bat";
    msbuild = "Common7\Tools\VsMSBuildCmd.bat";
    vsdevcmd = "Common7\Tools\VsDevCmd.bat";
  }
  IsSet = $false;
  Env = @{};
}
& {
  if ([System.Environment]::Is64BitOperatingSystem) {
    $ProVar.vcvars.Toolsets.cpp32 = $ProVar.vcvars.Toolsets.cpp32host64
    $ProVar.vcvars.Toolsets.cpp64 = $ProVar.vcvars.Toolsets.cpp64host64
    $ProVar.vcvars.Toolsets.cpparm = $ProVar.vcvars.Toolsets.cpparmhost64
    $ProVar.vcvars.Toolsets.cpp = $ProVar.vcvars.Toolsets.cpp64host64
  } else {
    $ProVar.vcvars.Toolsets.cpp32 = $ProVar.vcvars.Toolsets.cpp32host32
    $ProVar.vcvars.Toolsets.cpp64 = $ProVar.vcvars.Toolsets.cpp64host32
    $ProVar.vcvars.Toolsets.cpparm = $ProVar.vcvars.Toolsets.cpparmhost32
    $ProVar.vcvars.Toolsets.cpp = $ProVar.vcvars.Toolsets.cpp64host32
  }
  $ProVar.vcvars.Versions = ,(Get-ChildItem $ProVar.vcvars.Base |
                            Where Name -ine 'Installer' | % {
    $i = 0
    if (-not [int]::TryParse($_.Name, [ref]$i)) {
      $i = 999999
    }
    return @{
      Name = $_.Name;
      Rank = $i;
      Editions = ,(Get-ChildItem -Directory ($ProVar.vcvars.Base + '\' + $_.Name) | % Name);
    }
  } | Sort-Object -Property Rank)
}
# TODO: Make this look for more versions/editions
function vcvars {
  [CmdletBinding()]
  param(
    [switch]$Force = $false,
    [switch]$List = $false,
    [switch]$Unset = $false,
    [switch]$ShowEnv = $false
  )
  dynamicparam {
    $versions = $ProVar.vcvars.Versions | % Name
    $Version = $PSBoundParameters.Version
    if ($Version -eq $null) {
      $Version = $ProVar.vcvars.Versions[0].Name
    }
    $editions = ,($ProVar.vcvars.Versions | Where Name -ieq $Version | % Editions)
    $Edition = $editions[0]
    $PSBoundParameters.Version = $Version
    $PSBoundParameters.Edition = $Edition
    $PSBoundParameters.Toolset = 'cpp'
    New-DynamicParams |
      Add-DynamicParam Toolset -Alias 't' -Type:([string]) `
        -Values $ProVar.vcvars.Toolsets.Keys -NotNullOrEmpty |
      Add-DynamicParam Version -Alias 'v' -Type:([string]) `
        -Values $versions -NotNullOrEmpty |
      Add-DynamicParam Edition -Alias 'e' -Type:([string]) `
        -Values $editions -NotNullOrEmpty
  }
  begin {
    $Version = $PSBoundParameters.Version
    $Edition = $PSBoundParameters.Edition
    $Toolset = $PSBoundParameters.Toolset
  }
  process {
    $dir = [System.IO.Path]::Combine(
      $ProVar.vcvars.Base,
      $Version,
      $Edition,
      $ProVar.vcvars.Toolsets[$Toolset]
    )

    if ($List) {
      Write-Host "Versions:"
      $ProVar.vcvars.Versions | % {
        Write-Host ("* " + $_.Name + ": " + ($_.Editions -join ', '))
      }
      Write-Host "Toolsets:"
      $ProVar.vcvars.Toolsets.Keys | % {
        Write-Host ("* " + $_ + ": " + $ProVar.vcvars.Toolsets[$_])
      }
      return
    }

    if ($ShowEnv) {
      if ($ProVar.vcvars.Env.Count -eq 0) {
        Write-Host "Environment:`n* <empty>"
        return
      }

      Write-Host "Environment:`n"
      foreach ($k in $ProVar.vcvars.Env.Keys) {
        $v = $ProVar.vcvars.Env[$k]
        Write-Host ("* " + $k)
        if ($v -eq $null) {
          Write-Host "  - <null>"
        } else {
          Write-Host ("  - " + $v)
        }
        $old = Get-Content "Env:\$k" -ErrorAction Ignore
        if ($old -eq $null) {
          Write-Host " + <null>"
        } else {
          Write-Host "  + $old`n"
        }
      }
      return
    }

    if ($Unset) {
      if ($ProVar.vcvars.Env.Count -eq 0) {
        Write-Host "Nothing to do!"
        return
      }
      foreach ($k in $ProVar.vcvars.Env.Keys) {
        $v = $ProVar.vcvars.Env[$k]
        if ($v -eq $null) {
          Remove-Item "Env:\$k"
        } else {
          Set-Content "Env:\$k" $v
        }
      }
      $ProVar.vcvars.Env = @{}
      $ProVar.vcvars.IsSet = $false
      Write-Host "Yo bidness is all back to normal dawwwwggggg!"
      return
    }

    if (-not (Test-Path $dir -PathType Leaf)) {
      Write-Host "Dawg. `$ProVar.vcvars is wack!"
      return
    }

    if ($ProVar.vcvars.IsSet -and -not $Force) {
      Write-Host "Aw dawg you savin like 3 to 4 seconds cuz its already set!"
      return;
    }
    $output = cmd /c "`"$dir`" & set"
    if ($LASTEXITCODE -ne 0) {
      Write-Host "Aw hell nah dawg stuff didn't work!"
      return
    }
    $output | ?{$_ -match "^[A-Za-z_0-9]+="} | %{
      $var = $_
      $eq = $var.IndexOf('=');
      $key = $var.Substring(0, $eq);
      $val = $var.Substring($eq + 1);
      $old = Get-Content "Env:\$key" -ErrorAction Ignore
      if ($old -ne $val) {
        # New or updated var
        $ProVar.vcvars.Env[$key] = $old
        Set-Content "Env:\$key" "$val"
      }
    }
    $ProVar.vcvars.IsSet = $true
    Write-Host "Dawg, vcvars is r-r-r-ready to roll"
  }
}

Set-Alias which where.exe

$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}
