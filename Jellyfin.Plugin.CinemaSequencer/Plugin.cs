using System;
using System.Collections.Generic;
using Jellyfin.Plugin.CinemaSequencer.Configuration;
using MediaBrowser.Common.Configuration;
using MediaBrowser.Common.Plugins;
using MediaBrowser.Model.Plugins;
using MediaBrowser.Model.Serialization;

namespace Jellyfin.Plugin.CinemaSequencer
{
    public class Plugin : BasePlugin<PluginConfiguration>, IHasWebPages
    {
        public override string Name => "Cinema Sequencer";

        public override string Description =>
            "Downloads trailers, then plays N trailers followed by your own intro before each movie. Fork of Trailers4Jellyfin by robadieNZ (MIT).";

        public override Guid Id => Guid.Parse("b7c1e2a4-5d3f-4c8a-9e61-2f0a7d4b1c93");

        public static Plugin Instance { get; private set; } = null!;

        public Plugin(IApplicationPaths applicationPaths, IXmlSerializer xmlSerializer)
            : base(applicationPaths, xmlSerializer)
        {
            Instance = this;
        }

        public IEnumerable<PluginPageInfo> GetPages()
        {
            yield return new PluginPageInfo
            {
                Name = Name,
                EmbeddedResourcePath = GetType().Namespace + ".Configuration.config.html"
            };
        }
    }
}
