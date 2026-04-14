import { tracked } from "@glimmer/tracking";
import Controller from "@ember/controller";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { i18n } from "discourse-i18n";

export default class LicensingController extends Controller {
  @service toasts;
  @tracked licenseKey = "";
  @tracked licensed = null;
  @tracked _telemetryEnabled = null;

  get isLicensed() {
    return this.licensed ?? this.model?.licensed ?? false;
  }

  get telemetryEnabled() {
    return this._telemetryEnabled ?? this.model?.telemetry_enabled ?? true;
  }

  @action
  async activateLicense() {
    try {
      const result = await ajax(
        `/admin/plugins/domniq-mobile-app/licensing/activate.json`,
        { type: "POST", data: { license_key: this.licenseKey } }
      );
      this.licensed = result.licensed;
      this.toasts.success({
        data: { message: i18n("domniq_app.admin.licensing.activated") },
        duration: 2000,
      });
    } catch (e) {
      popupAjaxError(e);
    }
  }

  @action
  async checkLicense() {
    try {
      const result = await ajax(
        `/admin/plugins/domniq-mobile-app/licensing/check.json`,
        { type: "POST" }
      );
      this.licensed = result.licensed;
    } catch (e) {
      popupAjaxError(e);
    }
  }

  @action
  updateLicenseKey(event) {
    this.licenseKey = event.target.value;
  }

  @action
  async toggleTelemetry() {
    const newValue = !this.telemetryEnabled;
    try {
      await ajax(
        `/admin/plugins/domniq-mobile-app/licensing/telemetry.json`,
        { type: "PUT", data: { telemetry_enabled: newValue } }
      );
      this._telemetryEnabled = newValue;
      this.toasts.success({
        data: { message: i18n("domniq_app.admin.licensing.telemetry_saved") },
        duration: 2000,
      });
    } catch (e) {
      popupAjaxError(e);
    }
  }
}
