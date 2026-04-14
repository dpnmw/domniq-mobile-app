export default {
  resource: "admin.adminPlugins.show",

  path: "/plugins",

  map() {
    this.route("overview");
    this.route("configuration");
    this.route("drawer");
    this.route("features");
    this.route("notifications");
    this.route("language");
    this.route("licensing");
  },
};
