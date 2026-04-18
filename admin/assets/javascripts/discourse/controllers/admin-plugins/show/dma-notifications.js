import { tracked } from "@glimmer/tracking";
import Controller from "@ember/controller";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { i18n } from "discourse-i18n";

export default class DmaNotificationsController extends Controller {
  @service toasts;

  @tracked _pushEnabled = null;
  @tracked stats = null;
  @tracked searchUsername = "";
  @tracked searchResults = [];
  @tracked isSearching = false;
  @tracked hasSearched = false;
  @tracked isLocked = true;

  constructor() {
    super(...arguments);
    this._fetchLicense();
  }

  async _fetchLicense() {
    try {
      const result = await ajax("/admin/plugins/domniq-mobile-app/license/status.json");
      this.isLocked = !result.licensed;
    } catch {
      this.isLocked = true;
    }
  }

  get pushNotificationsEnabled() {
    return this._pushEnabled ?? this.model?.push_notifications_enabled ?? false;
  }

  get computedStats() {
    return this.stats ?? this.model?.stats ?? { total: 0, ios: 0, android: 0 };
  }

  @action
  async togglePushNotifications() {
    const newValue = !this.pushNotificationsEnabled;
    try {
      await ajax(
        `/admin/plugins/domniq-mobile-app/notifications/settings.json`,
        { type: "PUT", data: { push_notifications_enabled: newValue } }
      );
      this._pushEnabled = newValue;
      this.toasts.success({
        data: { message: i18n("domniq_app.admin.notifications.setting_saved") },
        duration: 2000,
      });
    } catch (e) {
      popupAjaxError(e);
    }
  }

  @action
  updateSearchUsername(event) {
    this.searchUsername = event.target.value;
  }

  @action
  async searchDevices() {
    if (!this.searchUsername.trim()) return;
    this.isSearching = true;
    this.hasSearched = false;
    try {
      const result = await ajax(
        `/admin/plugins/domniq-mobile-app/notifications/search.json`,
        { type: "GET", data: { username: this.searchUsername.trim() } }
      );
      this.searchResults = result.subscriptions;
      this.hasSearched = true;
    } catch (e) {
      popupAjaxError(e);
    } finally {
      this.isSearching = false;
    }
  }

  @action
  async removeSubscription(subscription) {
    try {
      await ajax(
        `/admin/plugins/domniq-mobile-app/notifications/subscriptions/${subscription.id}.json`,
        { type: "DELETE" }
      );
      this.searchResults = this.searchResults.filter(
        (s) => s.id !== subscription.id
      );
      this.stats = {
        ...this.computedStats,
        total: Math.max(0, this.computedStats.total - 1),
        [subscription.platform]: Math.max(
          0,
          this.computedStats[subscription.platform] - 1
        ),
      };
      this.toasts.success({
        data: { message: i18n("domniq_app.admin.notifications.removed") },
        duration: 2000,
      });
    } catch (e) {
      const code = e?.jqXHR?.responseJSON?.code;
      const message = e?.jqXHR?.responseJSON?.error;

      if (code === "subscription_missing") {
        this.toasts.warning({
          data: {
            message:
              message ||
              i18n("domniq_app.admin.notifications.subscription_missing"),
          },
          duration: 3000,
        });
      } else {
        popupAjaxError(e);
      }
    } finally {
      // Always refresh the search so deleted subscriptions disappear from the UI.
      if (this.searchUsername.trim()) {
        try {
          await this.searchDevices();
        } catch {
          // Non-fatal; the admin can manually re-search
        }
      }
    }
  }

  @action
  async sendTestPush(subscription) {
    try {
      await ajax(
        `/admin/plugins/domniq-mobile-app/notifications/test.json`,
        { type: "POST", data: { subscription_id: subscription.id } }
      );
      this.toasts.success({
        data: { message: i18n("domniq_app.admin.notifications.test_sent") },
        duration: 2000,
      });
    } catch (e) {
      const code = e?.jqXHR?.responseJSON?.code;
      const message = e?.jqXHR?.responseJSON?.error;

      if (code === "subscription_missing") {
        this.toasts.warning({
          data: {
            message:
              message ||
              i18n("domniq_app.admin.notifications.subscription_missing"),
          },
          duration: 3000,
        });
      } else {
        popupAjaxError(e);
      }
    } finally {
      // Always refresh the search so stale subscriptions (e.g. from a logout/
      // login cycle) disappear from the UI automatically.
      if (this.searchUsername.trim()) {
        try {
          await this.searchDevices();
        } catch {
          // Non-fatal; the admin can manually re-search
        }
      }
    }
  }

  @action
  async runCleanup() {
    try {
      const result = await ajax(
        `/admin/plugins/domniq-mobile-app/notifications/cleanup.json`,
        { type: "POST" }
      );
      this.stats = {
        ...this.computedStats,
        total: Math.max(0, this.computedStats.total - result.deleted),
      };
      this.toasts.success({
        data: {
          message: i18n("domniq_app.admin.notifications.cleanup_complete", {
            count: result.deleted,
          }),
        },
        duration: 3000,
      });
    } catch (e) {
      popupAjaxError(e);
    }
  }
}
