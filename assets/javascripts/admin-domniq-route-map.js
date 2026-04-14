export default {
  resource: "admin.adminPlugins.show",

  path: "/plugins",

  map() {
    this.route("domniq-overview");
    this.route("domniq-configuration");
    this.route("domniq-drawer");
    this.route("domniq-features");
    this.route("domniq-notifications");
    this.route("domniq-language");
    this.route("domniq-licensing");
  },
};
