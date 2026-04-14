import { tracked } from "@glimmer/tracking";
import Controller from "@ember/controller";
import { action } from "@ember/object";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";

export default class DomniqLicensingController extends Controller {
  @tracked licenseKey = "";
  @tracked licensed = null;

  get isLicensed() {
    return this.licensed ?? this.model?.licensed ?? false;
  }

  @action
  async activateLicense() {
    try {
      const result = await ajax(
        `/admin/plugins/domniq/licensing/activate.json`,
        { type: "POST", data: { license_key: this.licenseKey } }
      );
      this.licensed = result.licensed;
    } catch (e) {
      popupAjaxError(e);
    }
  }

  @action
  async checkLicense() {
    try {
      const result = await ajax(
        `/admin/plugins/domniq/licensing/check.json`,
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
}
