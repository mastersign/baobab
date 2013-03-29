using System;
using System.Collections.Generic;
using System.IO;
using System.Runtime.InteropServices;
using System.Text;

namespace net.kiertscher.toolbox.filesystem
{
    public static class IniFile
    {
        [DllImport("kernel32.dll")]
        private static extern uint GetPrivateProfileString(
            string lpAppName,
            string lpKeyName,
            string lpDefault,
            StringBuilder lpReturnedString,
            uint nSize,
            string lpFileName);

        [DllImport("kernel32.dll")]
        private static extern bool WritePrivateProfileString(string lpAppName,
                                                             string lpKeyName, string lpString, string lpFileName);

        public static bool SetValue(string file, string category, string key, string value)
        {
            return WritePrivateProfileString(category, key, value, file);
        }

        public static string GetValue(string file, string category, string key, string defValue)
        {
            var sb = new StringBuilder(1024);
            GetPrivateProfileString(category, key, defValue, sb, (uint)sb.Capacity, file);
            return sb.ToString();
        }
    }
}