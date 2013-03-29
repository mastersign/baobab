namespace net.kiertscher.baobab.shell
{
    partial class ShellDialog
    {
        /// <summary>
        /// Erforderliche Designervariable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Verwendete Ressourcen bereinigen.
        /// </summary>
        /// <param name="disposing">True, wenn verwaltete Ressourcen gelöscht werden sollen; andernfalls False.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Vom Windows Form-Designer generierter Code

        /// <summary>
        /// Erforderliche Methode für die Designerunterstützung.
        /// Der Inhalt der Methode darf nicht mit dem Code-Editor geändert werden.
        /// </summary>
        private void InitializeComponent()
        {
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(ShellDialog));
            this.btnClose = new System.Windows.Forms.Button();
            this.shellControl = new de.mastersign.shell.GraphicalShellControl();
            this.SuspendLayout();
            // 
            // btnClose
            // 
            this.btnClose.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.btnClose.Location = new System.Drawing.Point(637, 327);
            this.btnClose.Name = "btnClose";
            this.btnClose.Size = new System.Drawing.Size(75, 23);
            this.btnClose.TabIndex = 1;
            this.btnClose.Text = "S&chließen";
            this.btnClose.UseVisualStyleBackColor = true;
            // 
            // shellControl
            // 
            this.shellControl.Buffer = null;
            this.shellControl.CancelButtonEnabled = false;
            this.shellControl.CursorBlinkInterval = 500;
            this.shellControl.CursorMode = de.mastersign.shell.ConsoleDisplay.CursorShowMode.Hide;
            this.shellControl.Dock = System.Windows.Forms.DockStyle.Fill;
            this.shellControl.Location = new System.Drawing.Point(0, 0);
            this.shellControl.Name = "shellControl";
            this.shellControl.ProcessKeyStrokes = true;
            this.shellControl.PromptText = "C:\\Windows\\system32\\>";
            this.shellControl.Size = new System.Drawing.Size(724, 362);
            this.shellControl.TabIndex = 2;
            // 
            // ShellDialog
            // 
            this.AcceptButton = this.btnClose;
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(724, 362);
            this.Controls.Add(this.shellControl);
            this.Controls.Add(this.btnClose);
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.Name = "ShellDialog";
            this.Text = "Entity Management Shell";
            this.Activated += new System.EventHandler(this.ShellDialog_Activated);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Button btnClose;
        private de.mastersign.shell.GraphicalShellControl shellControl;
    }
}