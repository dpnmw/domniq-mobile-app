import { tracked } from "@glimmer/tracking";
import Controller from "@ember/controller";
import { action } from "@ember/object";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";

export default class NotificationsController extends Controller {
  @tracked subscriptions = null;

  get computedSubscriptions() {
    return this.subscriptions ?? this.model?.subscriptions ?? [];
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
    } catch (e) {
      popupAjaxError(e);
    }
  }
}
