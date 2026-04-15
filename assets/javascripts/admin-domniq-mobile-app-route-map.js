export default {
  resource: "admin.adminPlugins.show",

  path: "/plugins",

  map() {
    this.route("dma-overview");
    this.route("dma-configuration");
    this.route("dma-drawer");
    this.route("dma-features");
    this.route("dma-notifications");
    this.route("dma-language");
    this.route("dma-premium");
  },
};
