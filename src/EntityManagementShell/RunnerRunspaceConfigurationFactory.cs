using System.Management.Automation.Runspaces;
using de.mastersign.shell;

namespace net.kiertscher.baobab.shell
{
    internal class RunnerRunspaceConfigurationFactory : IRunspaceConfigurationFactory
    {
        public RunspaceConfiguration CreateRunspaceConfiguration()
        {
            var ret = RunspaceConfiguration.Create();
            ret.InitializationScripts.Reset();
            ret.Scripts.Reset();
            return ret;
        }
    }
}