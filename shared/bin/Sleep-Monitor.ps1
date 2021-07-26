param(
  [switch]$Now,
  [switch]$NoLock,
  [switch]$MonitorOn
)

if ($NoLock -and $MonitorOn) {
  Write-Output "Nothing to do!"
  exit 1
}

Add-Type -TypeDefinition '
using System;
using System.Runtime.InteropServices;

namespace Utilities {
  public static class Display {
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    private static extern IntPtr SendMessage(
      IntPtr hWnd,
      UInt32 Msg,
      IntPtr wParam,
      IntPtr lParam
    );

    [DllImport("user32.dll")]
    private static extern bool LockWorkStation();

    public static void Lock() {
      LockWorkStation();
    }

    public static void PowerOff() {
      SendMessage(
        (IntPtr)0xffff, // HWND_BROADCAST
        0x0112,         // WM_SYSCOMMAND
        (IntPtr)0xf170, // SC_MONITORPOWER
        (IntPtr)0x0002  // POWER_OFF
      );
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
if (!$MonitorOn) {
  [Utilities.Display]::PowerOff()
}
if (!$NoLock) {
  [Utilities.Display]::Lock();
}
