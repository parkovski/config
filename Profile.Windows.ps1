& {
  [System.UInt16]$page=0
  if (-not (Test-Path Env:\CODEPAGE)) {
    $page = 65001
  } else {
    [System.UInt16]::TryParse($env:CODEPAGE, [ref]$page)
  }
  if ($page) {
    chcp $page | Out-Null
  }
}

function local:TryToImport {
  param([Parameter(Position=0)][string]$Path)
  if (Test-Path $Path) {
    Import-Module $Path
  }
}

TryToImport "$GH\3rd-party\vcpkg\scripts\posh-vcpkg"
TryToImport "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"

function Restart-Explorer {
  Stop-Process -Name explorer
}
Set-Alias rsex Restart-Explorer

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

function wslpath {
  param([string]$Path)
  wsl.exe -e wslpath -u ($Path -replace '\\','\\\\')
}

# Fix missing Set-Clipboard.
if (-not (Get-Command Set-Clipboard -ErrorAction Ignore)) {
  function Set-Clipboard {
    param(
      [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
      [string]$Text
    )

    $Text += [char]0
    $Text | clip.exe
  }
}

Set-Alias which where.exe

# C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\Common7\Tools\VsDevCmd.bat
# C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvars64.bat
$ProVar.vcvars = @{
  Base = "C:\Program Files\Microsoft Visual Studio";
  Toolsets = @{
    # 32 bit compiler
    cpp32host32 = "VC\Auxiliary\Build\vcvars32.bat";
    cpp64host32 = "VC\Auxiliary\Build\vcvarsx86_amd64.bat";
    cpparmhost32 = "VC\Auxiliary\Build\vcvarsx86_arm.bat";
    cpparm64host32 = "VC\Auxiliary\Build\vcvarsx86_arm64.bat";

    # 64 bit compiler
    cpp64host64 = "VC\Auxiliary\Build\vcvars64.bat";
    cpp32host64 = "VC\Auxiliary\Build\vcvarsamd64_x86.bat";
    cpparmhost64 = "VC\Auxiliary\Build\vcvarsamd64_arm.bat";
    cpparm64host64 = "VC\Auxiliary\Build\vcvarsamd64_arm64.bat";

    #launchdevcmd = "Common7\Tools\LaunchDevCmd.bat";
    msbuild = "Common7\Tools\VsMSBuildCmd.bat";
    vsdevcmd = "Common7\Tools\VsDevCmd.bat";
    #launchvsdevshell = "Common7\Tools\Launch-VsDevShell.ps1";
  }
  IsSet = $false;
  Env = @{};
  DefaultVersion = '2022';
}

if ([System.Environment]::Is64BitOperatingSystem) {
  $ProVar.vcvars.Toolsets.cpp32 = $ProVar.vcvars.Toolsets.cpp32host64
  $ProVar.vcvars.Toolsets.cpp64 = $ProVar.vcvars.Toolsets.cpp64host64
  $ProVar.vcvars.Toolsets.cpparm = $ProVar.vcvars.Toolsets.cpparmhost64
  $ProVar.vcvars.Toolsets.cpparm64 = $ProVar.vcvars.Toolsets.cpparm64host64
  $ProVar.vcvars.Toolsets.cpp = $ProVar.vcvars.Toolsets.cpp64host64
} else {
  $ProVar.vcvars.Toolsets.cpp32 = $ProVar.vcvars.Toolsets.cpp32host32
  $ProVar.vcvars.Toolsets.cpp64 = $ProVar.vcvars.Toolsets.cpp64host32
  $ProVar.vcvars.Toolsets.cpparm = $ProVar.vcvars.Toolsets.cpparmhost32
  $ProVar.vcvars.Toolsets.cpparm64 = $ProVar.vcvars.Toolsets.cpparm64host32
  $ProVar.vcvars.Toolsets.cpp = $ProVar.vcvars.Toolsets.cpp32host32
}
$ProVar.vcvars.Versions = @(Get-ChildItem $ProVar.vcvars.Base | ForEach-Object {
  return @{
    Name = $_.Name;
    Editions = @( `
      Get-ChildItem -Directory $_ `
      | Where-Object { Test-Path -PathType Container "$_\Common7\Tools" } `
      | ForEach-Object Name `
    );
  }
}) | Where-Object { $_.Editions -and $_.Editions.Length -gt 0 } `
   | Sort-Object -Descending -Property Name

function vcvars {
  [CmdletBinding()]
  param(
    [switch]$Force = $false,
    [switch]$List = $false,
    [switch]$Unset = $false,
    [switch]$ShowEnv = $false,
    [Alias('v')]
    [ValidateSet('2017', '2019', '2022')]
    [string]
    $Version
  )
  dynamicparam {
    if ([string]::IsNullOrEmpty($Version)) {
      $Version = $ProVar.vcvars.DefaultVersion
    }
    $editions = @($ProVar.vcvars.Versions `
      | Where-Object Name -ieq $Version `
      | ForEach-Object Editions)
    $params = New-DynamicParams `
            | Add-DynamicParam Toolset -Alias 't' -Type:([string]) `
              -Values $ProVar.vcvars.Toolsets.Keys `
            | Add-DynamicParam Edition -Alias 'e' -Type:([string]) `
              -Values $editions

    $params
  }
  begin {
    if ([string]::IsNullOrEmpty($Version)) {
      $Version = $ProVar.vcvars.DefaultVersion
    }
    $Edition = $PSBoundParameters.Edition
    if (-not $Edition) {
      $Edition = $editions[0]
    }
    $Toolset = $PSBoundParameters.Toolset
    if (-not $Toolset) {
      $Toolset = 'cpp'
    }
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
      $ProVar.vcvars.Versions | ForEach-Object {
        Write-Host ("* " + $_.Name + ": " + ($_.Editions -join ', '))
      }
      Write-Host "Toolsets:"
      $ProVar.vcvars.Toolsets.Keys | ForEach-Object {
        Write-Host ("* " + $_ + ": " + $ProVar.vcvars.Toolsets[$_])
      }
      return
    }

    if ($ShowEnv) {
      if ($ProVar.vcvars.Env.Count -eq 0) {
        Write-Host "Environment: <empty>"
        return
      }

      Write-Host "Environment:`n"
      foreach ($k in $ProVar.vcvars.Env.Keys) {
        $old = $ProVar.vcvars.Env[$k]
        $v = Get-Content "Env:\$k" -ErrorAction Ignore
        if (-not $v) {
          Write-Host "- $k"
        } elseif (-not $old) {
          Write-Host "+ $k = $v"
        } else {
          Write-Host "= $k = $v"
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
        if ([string]::IsNullOrEmpty($v)) {
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
      Write-Host $dir
      return
    }

    if ($ProVar.vcvars.IsSet -and -not $Force) {
      Write-Host "Aw dawg you savin like 3 to 4 seconds cuz its already set!"
      return;
    }
    # I hate you guys
    $env:VSCMD_SKIP_SENDTELEMETRY=1
    $output = cmd /c "`"$dir`" & set"
    if ($LASTEXITCODE -ne 0) {
      Write-Host "Aw hell nah dawg stuff didn't work!"
      return
    }
    $output | Where-Object {$_ -match "^[A-Za-z_0-9]+="} | ForEach-Object {
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
    Write-Host "Dawg, vcvars is r-r-r-ready to roll!"
  }
}
