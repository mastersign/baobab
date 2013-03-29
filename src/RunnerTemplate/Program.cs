using System;
using System.IO;
using System.Windows.Forms;
using net.kiertscher.baobab.runner.Properties;
using System.Diagnostics;

namespace net.kiertscher.baobab.runner
{
    static class Program
    {
        [STAThread]
        static void Main()
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);

            string entityManagement = 
                EntityManagementFinder.GetManagementRoot();
            if (entityManagement == null)
            {
                return;
            }

            string scriptFile;
            if (!RetrieveScriptFile(entityManagement, out scriptFile))
            {
                MessageBox.Show(string.Format(
                    "Could not find the specified PowerShell script file.{0}{0}{1}",
                    Environment.NewLine, scriptFile),
                    "Script file not found",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error);
                return;
            }

            ExecuteScript(entityManagement, scriptFile);
            Environment.Exit(0);
        }

        private static bool RetrieveScriptFile(string entityManagement, out string path)
        {
            var fileName = Resources.ScriptFile;
            if (string.IsNullOrEmpty(fileName))
            {
                fileName = Path.GetFileName(Application.ExecutablePath);
            }
            if (!Path.IsPathRooted(Resources.ScriptPath))
            {
                if (Resources.UseEntityManagement.Equals("true", StringComparison.InvariantCultureIgnoreCase))
                {
                    path = entityManagement;
                    if (path == null)
                    {
                        return false;
                    }
                }
                else
                {
                    path = Application.StartupPath;
                }
                path = Path.Combine(path, Resources.ScriptPath);
            }
            else
            {
                path = Resources.ScriptPath;
            }
            path = Path.Combine(path, fileName);

            return File.Exists(path);
        }

        private static void ExecuteScript(string entityManagement, string file)
        {
            string shell = Path.Combine(entityManagement, @"assemblies\EntityManagementShell.exe");
            if (!File.Exists(shell))
            {
                MessageBox.Show(string.Format(
                    "Could not find the executable of the entity management shell.{0}{0}",
                    Environment.NewLine, shell), 
                    "Execute script...",
                    MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }
            var startInfo = new ProcessStartInfo(shell, "\"" + file + "\"");
            startInfo.UseShellExecute = false;
            startInfo.WorkingDirectory = Application.StartupPath;
            var execProc = Process.Start(startInfo);
        }
    }
}