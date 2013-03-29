using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Text;

namespace net.kiertscher.toolbox.windows
{
    public enum GetWindow_Cmd : uint {
       GW_HWNDFIRST = 0,
       GW_HWNDLAST = 1,
       GW_HWNDNEXT = 2,
       GW_HWNDPREV = 3,
       GW_OWNER = 4,
       GW_CHILD = 5,
       GW_ENABLEDPOPUP = 6
    }

    public static class Shell
    {
        [DllImport("user32.dll")]
        public static extern IntPtr GetTopWindow(IntPtr hWnd);

        [DllImport("user32.dll", SetLastError = true)]
        public static extern IntPtr GetWindow(IntPtr hWnd, GetWindow_Cmd uCmd);
        
        [DllImport("user32.dll", SetLastError = false)]
        public static extern IntPtr GetDesktopWindow();

        public static IntPtr GetTopMostWindow(IntPtr[] hWnds)
        {
            if (hWnds.Length == 0)
            {
                throw new ArgumentException(
                    "At least one window handle must be provided.", "hWnds");
            }

            var h = GetWindow(hWnds[0], GetWindow_Cmd.GW_HWNDFIRST);
            while (h != IntPtr.Zero)
            {
                if (HwndArrayContains(hWnds, h))
                {
                    return h;
                }
                h = GetWindow(h, GetWindow_Cmd.GW_HWNDNEXT);
            }
            return IntPtr.Zero;
        }

        private static bool HwndArrayContains(IEnumerable<IntPtr> hWnds, IntPtr hWnd)
        {
            foreach(var hWnd1 in hWnds)
            {
                if (hWnd1 == hWnd)
                {
                    return true;
                }
            }
            return false;
        }
    }
}
