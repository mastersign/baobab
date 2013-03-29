using System;
using System.Windows.Forms;
using System.Collections;

namespace net.kiertscher.toolbox.windows
{
    public partial class SelectListDialog : Form
    {
        public static object[] ShowDialog(string title, string message, IEnumerable listItems)
        {
            var dlg = new SelectListDialog();
            dlg.Text = title;
            dlg.lblDescription.Text = message;
            foreach (var o in listItems)
            {
                dlg.list.Items.Add(o);
            }
            if (dlg.ShowDialog() == DialogResult.OK)
            {
                var ret = new ArrayList();
                ret.AddRange(dlg.list.SelectedItems);
                return ret.ToArray();
            }
            else
            {
                return new object[0];
            }
        }

        public SelectListDialog()
        {
            InitializeComponent();
            DialogResult = DialogResult.Cancel;
        }

        private void btnOK_Click(object sender, EventArgs e)
        {
            DialogResult = DialogResult.OK;
            Close();
        }
    }
}
