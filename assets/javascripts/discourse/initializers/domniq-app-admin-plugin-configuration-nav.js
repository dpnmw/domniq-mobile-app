import { withPluginApi } from "discourse/lib/plugin-api";

const PLUGIN_ID = "domniq-mobile-app";

export default {
  name: "domniq-app-admin-plugin-configuration-nav",

  initialize(container) {
    const currentUser = container.lookup("service:current-user");
    if (!currentUser?.admin) {
      return;
    }

    withPluginApi((api) => {
      api.addAdminPluginConfigurationNav(PLUGIN_ID, [
        {
          label: "domniq_app.admin.overview.title",
          route: "adminPlugins.show.dma-overview",
        },
        {
          label: "domniq_app.admin.configuration.title",
          route: "adminPlugins.show.dma-configuration",
        },
        {
          label: "domniq_app.admin.drawer.title",
          route: "adminPlugins.show.dma-drawer",
        },
        {
          label: "domniq_app.admin.features.title",
          route: "adminPlugins.show.dma-features",
        },
        {
          label: "domniq_app.admin.notifications.title",
          route: "adminPlugins.show.dma-notifications",
        },
        {
          label: "domniq_app.admin.language.title",
          route: "adminPlugins.show.dma-language",
        },
        {
          label: "domniq_app.admin.licensing.title",
          route: "adminPlugins.show.dma-premium",
        },
      ]);
    });
  },
};
