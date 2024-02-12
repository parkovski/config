param(
  [Alias('n')][switch]$Now,
  [Alias('l')][switch]$Lock,
  [Alias('u')][switch]$NoLock,
  [ValidateSet('Off', 'On', 'Low', 'None')][Alias('s')][string]$PowerState = 'Off'
)

if (($NoLock -or (-not $Lock)) -and $PowerState -ieq 'None') {
  Write-Output "Nothing to do!"
  exit 1
}

Add-Type -TypeDefinition '
using System;
using System.Runtime.InteropServices;

namespace Utilities {
  public static class Display {
    [DllImport("user32.dll")]
    private static extern IntPtr GetShellWindow();

    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    private static extern IntPtr PostMessage(
      IntPtr hWnd,
      UInt32 Msg,
      IntPtr wParam,
      IntPtr lParam
    );

    //private static readonly IntPtr HWND_BROADCAST = (IntPtr)0xffff;
    private static readonly UInt32 WM_SYSCOMMAND = 0x0112;
    private static readonly IntPtr SC_MONITORPOWER = (IntPtr)0xf170;

    [DllImport("user32.dll")]
    private static extern bool LockWorkStation();

    public static void Lock() {
      LockWorkStation();
    }

    public static readonly IntPtr POWER_OFF = (IntPtr)2;
    public static readonly IntPtr POWER_LOW = (IntPtr)1;
    public static readonly IntPtr POWER_ON = (IntPtr)(-1);

    public static void SetMonitorPower(IntPtr state) {
      if (state == IntPtr.Zero) { return; }
      PostMessage(GetShellWindow(), WM_SYSCOMMAND, SC_MONITORPOWER, state);
    }
  }
}
'

if (!$Now) {
  Write-Output "And a-three!"
  Start-Sleep 1
  Write-Output "And a-two!"
  Start-Sleep 1
  Write-Output "And a-one!"
  Start-Sleep 1
}
$state = [System.IntPtr]::Zero
switch ($PowerState) {
  'Off' { $state = [Utilities.Display]::POWER_OFF; $Lock = $true; break }
  'On'  { $state = [Utilities.Display]::POWER_ON ; break }
  'Low' { $state = [Utilities.Display]::POWER_LOW; break }
  default { break }
}
[Utilities.Display]::SetMonitorPower($state)
if ($Lock -and (-not $NoLock)) {
  [Utilities.Display]::Lock();
}
