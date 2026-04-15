import { tracked } from "@glimmer/tracking";
import Controller from "@ember/controller";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { i18n } from "discourse-i18n";

export default class PremiumController extends Controller {
  @service toasts;
  @tracked licenseKey = "";
  @tracked licensed = null;
  @tracked licenseError = null;
  @tracked _telemetryEnabled = null;

  get isLicensed() {
    return this.licensed ?? this.model?.licensed ?? false;
  }

  get telemetryEnabled() {
    return this._telemetryEnabled ?? this.model?.telemetry_enabled ?? true;
  }

  @action
  async activateLicense() {
    if (!this.licenseKey.trim()) return;
    this.licenseError = null;
    try {
      const result = await ajax(
        `/admin/plugins/domniq-mobile-app/licensing/activate.json`,
        { type: "POST", data: { license_key: this.licenseKey.trim() } }
      );
      this.licensed = result.licensed;
      if (result.licensed) {
        this.licenseKey = "";
        this.toasts.success({
          data: { message: "Licence activated successfully" },
          duration: 3000,
        });
      }
    } catch (e) {
      const msg = e.jqXHR?.responseJSON?.error || "Activation failed. Please check your licence key.";
      this.licenseError = msg;
      this.toasts.error({ data: { message: msg }, duration: 5000 });
    }
  }

  @action
  async checkLicense() {
    this.licenseError = null;
    try {
      const result = await ajax(
        `/admin/plugins/domniq-mobile-app/licensing/check.json`,
        { type: "POST" }
      );
      this.licensed = result.licensed;
      if (result.licensed) {
        this.toasts.success({ data: { message: "Licence is valid and active" }, duration: 3000 });
      } else {
        const msg = result.error || "Licence is inactive.";
        this.licenseError = msg;
        this.toasts.error({ data: { message: msg }, duration: 5000 });
      }
    } catch (e) {
      this.licenseError = "Unable to verify licence. Please try again later.";
      this.toasts.error({ data: { message: this.licenseError }, duration: 5000 });
    }
  }

  @action
  updateLicenseKey(event) {
    this.licenseKey = event.target.value;
    this.licenseError = null;
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
