import { tracked } from "@glimmer/tracking";
import Controller from "@ember/controller";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { i18n } from "discourse-i18n";

export default class DmaNotificationsController extends Controller {
  @service toasts;
  @tracked subscriptions = null;
  @tracked _pushEnabled = null;

  get computedSubscriptions() {
    return this.subscriptions ?? this.model?.subscriptions ?? [];
  }

  get pushNotificationsEnabled() {
    return this._pushEnabled ?? this.model?.push_notifications_enabled ?? false;
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
  async removeSubscription(subscription) {
    try {
      await ajax(
        `/admin/plugins/domniq-mobile-app/notifications/subscriptions/${subscription.id}.json`,
        { type: "DELETE" }
      );
      this.subscriptions = this.computedSubscriptions.filter(
        (s) => s.id !== subscription.id
      );
    } catch (e) {
      popupAjaxError(e);
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
      popupAjaxError(e);
    }
  }
}
