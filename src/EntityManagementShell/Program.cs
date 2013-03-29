using System;
using System.IO;
using System.Windows.Forms;
using de.mastersign.shell;
using System.Collections;

namespace net.kiertscher.baobab.shell
{
    static class Program
    {
        [STAThread]
        static void Main(string[] args)
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);

            if (args.Length != 1 || !File.Exists(args[0]))
            {
                MessageBox.Show(
                    "A PowerShell script is expected to be provided via a command line argument.",
                    "No Script Specified", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                return;
            }
            Execute(args[0]);
        }

        private static GraphicalShell shell;

        private static void Execute(string scriptFile)
        {
            shell = new GraphicalShell();
            shell.StartShell(new RunnerRunspaceConfigurationFactory());
            shell.MoveBufferWindowPosition(0, 0);

            var baobabProperties = new Hashtable();
            baobabProperties["OpenWindow"] = false;
            shell.SetVariable("BaobabShell", baobabProperties);

            var cmd = new CommandInfo(scriptFile, null) { WriteDecorations = true, LocalScope = true };
            shell.InvokeSync(cmd);

            var openWindow = baobabProperties["OpenWindow"] is bool
                ? (bool)baobabProperties["OpenWindow"]
                : false;

            var ui = (BaseUI)shell.Host.UI;
            if (openWindow || ui.WarningWritten || ui.ErrorWritten)
            {
                var form = new ShellDialog(shell);
                Application.Run(form);
            }
        }

    }
}