using Jellyfin.Plugin.CinemaSequencer.ScheduledTasks;
using Jellyfin.Plugin.CinemaSequencer.Services;
using MediaBrowser.Controller;
using MediaBrowser.Controller.Library;
using MediaBrowser.Controller.Plugins;
using MediaBrowser.Model.Tasks;
using Microsoft.Extensions.DependencyInjection;

namespace Jellyfin.Plugin.CinemaSequencer
{
    public class PluginServiceRegistrator : IPluginServiceRegistrator
    {
        public void RegisterServices(IServiceCollection serviceCollection, IServerApplicationHost applicationHost)
        {
            serviceCollection.AddSingleton<TmdbService>();
            serviceCollection.AddSingleton<TrailerDownloadService>();
            serviceCollection.AddTransient<IScheduledTask, DownloadTrailersTask>();
            serviceCollection.AddSingleton<IIntroProvider, TrailerIntroProvider>();
        }
    }
}
