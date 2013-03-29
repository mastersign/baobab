using System;
using System.Collections.Generic;
using System.Text;
using System.IO;

namespace net.kiertscher.toolbox.filesystem
{
    public static class DirectoryTools
    {
        public static void Clean(string path, params string[] exclude)
        {
            var dirInfo = new DirectoryInfo(path);
            if (!dirInfo.Exists) return;

            foreach (var f in dirInfo.GetFiles())
            {
                if (IsExcluded(f.Name, exclude)) continue;
                f.Delete();
            }
            foreach (var d in dirInfo.GetDirectories())
            {
                if (IsExcluded(d.Name, exclude)) continue;
                d.Delete(true);
            }
        }

        private static bool IsExcluded(string name, string[] exclude)
        {
            foreach (var e in exclude)
            {
                if (name.Equals(e, StringComparison.InvariantCultureIgnoreCase))
                {
                    return true;
                }
            }
            return false;
        }

        /// <summary>
        /// Creates a relative path from one file
        /// or folder to another.
        /// </summary>
        /// <param name="fromDirectory">
        /// Contains the directory that defines the
        /// start of the relative path.
        /// </param>
        /// <param name="toPath">
        /// Contains the path that defines the
        /// endpoint of the relative path.
        /// </param>
        /// <returns>
        /// The relative path from the start
        /// directory to the end path.
        /// </returns>
        /// <exception cref="ArgumentNullException"/>
        public static string RelativePathTo(
            string fromDirectory, string toPath)
        {
            if (fromDirectory == null)
            {
                throw new ArgumentNullException("fromDirectory");
            }

            if (toPath == null)
            {
                throw new ArgumentNullException("toPath");
            }

            bool isRooted = Path.IsPathRooted(fromDirectory)
                            && Path.IsPathRooted(toPath);

            if (isRooted)
            {
                bool isDifferentRoot = string.Compare(
                    Path.GetPathRoot(fromDirectory),
                    Path.GetPathRoot(toPath), true) != 0;


                if (isDifferentRoot)
                {
                    return toPath;
                }
            }

            var relativePath = new List<string>();
            var fromDirectories = fromDirectory.Split(
                Path.DirectorySeparatorChar);
            var toDirectories = toPath.Split(
                Path.DirectorySeparatorChar);
            int length = Math.Min(fromDirectories.Length, toDirectories.Length);
            int lastCommonRoot = -1;

            // find common root
            for (int x = 0; x < length; x++)
            {
                if (string.Compare(
                    fromDirectories[x], toDirectories[x], true) != 0)
                {
                    break;
                }
                lastCommonRoot = x;
            }

            if (lastCommonRoot == -1)
            {
                return toPath;
            }

            // add relative folders in from path
            for (int x = lastCommonRoot + 1; x < fromDirectories.Length; x++)
            {
                if (fromDirectories[x].Length > 0)
                {
                    relativePath.Add("..");
                }
            }

            // add to folders to path
            for (int x = lastCommonRoot + 1; x < toDirectories.Length; x++)
            {
                relativePath.Add(toDirectories[x]);
            }

            // create relative path
            var relativeParts = new string[relativePath.Count];
            relativePath.CopyTo(relativeParts, 0);
            string newPath = string.Join(
                Path.DirectorySeparatorChar.ToString(),
                relativeParts);

            return newPath;
        }

    }
}
