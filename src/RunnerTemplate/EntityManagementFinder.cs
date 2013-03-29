using System;
using System.Collections.Generic;
using System.Text;
using System.IO;
using System.Windows.Forms;
using net.kiertscher.baobab.runner.Properties;
using System.Xml;

namespace net.kiertscher.baobab.runner
{
    internal class EntityManagementFinder
    {
        public static string GetManagementRoot()
        {
            var fileInfo = FindDescriptor(new DirectoryInfo(Application.StartupPath));
            if (fileInfo == null)
            {
                MessageBox.Show(string.Format(
                    "Could not find a configuration file 'entitymanagement.{1}.xml'.{0}{0}Starting point: {2}",
                    Environment.NewLine, Resources.ProfileName, Application.StartupPath),
                    "Determining script path...",
                    MessageBoxButtons.OK, MessageBoxIcon.Error);
                return null;
            }
            var doc = new XmlDocument();
            doc.Load(fileInfo.FullName);
            var tag = doc.SelectSingleNode("/EntityManagement/RootPath");
            if (tag == null)
            {
                MessageBox.Show(string.Format(
                    "The configuration file 'entitymanagement.{0}.xml' does not contain a root path tag.",
                    Resources.ProfileName),
                    "Determining script path...",
                    MessageBoxButtons.OK, MessageBoxIcon.Error);
                return null;
            }
            var path = tag.InnerText.Trim();
            if (!Path.IsPathRooted(path))
            {
                path = Path.Combine(fileInfo.DirectoryName, path);
            }
            return path;
        }

        private static FileInfo FindDescriptor(DirectoryInfo dir)
        {
            var fi = new FileInfo(Path.Combine(dir.FullName, "entitymanagement." + Resources.ProfileName + ".xml"));
            if (fi.Exists)
            {
                return fi;
            }
            var parentDir = dir.Parent;
            if (parentDir != null)
            {
                return FindDescriptor(parentDir);
            }
            else
            {
                return null;
            }
        }
    }
}
