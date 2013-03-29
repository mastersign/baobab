using System;
using System.Management.Automation.Host;
using System.Windows.Forms;
using de.mastersign.shell;

namespace net.kiertscher.baobab.shell
{
    public partial class ShellDialog : Form
    {
        public ShellDialog(GraphicalShell shell)
        {
            InitializeComponent();
            Icon = de.mastersign.shell.Properties.Resources.AppShell;
            shell.Exit += shell_Exit;
            shell.GraphicalShellControl = shellControl;
            shellControl.UseShell(shell);

            int pos = shell.Buffer.CursorPosition.Y -
                      shell.Buffer.WindowSize.Height;
            if (pos < 0) pos = 0;
            shell.Buffer.WindowPosition = new Coordinates(0, pos);
        }

        private void shell_Exit(object sender, ExitEventArgs e)
        {
            Environment.ExitCode = e.ExitCode;
            if (InvokeRequired)
            {
                Invoke((MethodInvoker)Close);
            }
            else
            {
                Close();
            }
        }

        private void ShellDialog_Activated(object sender, EventArgs e)
        {
            Focus();
        }
    }
}