import { tracked } from "@glimmer/tracking";
import Controller from "@ember/controller";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { i18n } from "discourse-i18n";

export default class DmaFeaturesController extends Controller {
  @service toasts;
  @tracked flags = null;
  @tracked _videoThumbnails = null;
  @tracked isLocked = true;

  constructor() {
    super(...arguments);
    this._fetchLicense();
  }

  async _fetchLicense() {
    try {
      const result = await ajax("/admin/plugins/domniq-mobile-app/licensing/status.json");
      this.isLocked = !result.licensed;
    } catch {
      this.isLocked = true;
    }
  }

  get computedFlags() {
    return this.flags ?? this.model?.flags ?? [];
  }

  get videoThumbnailsEnabled() {
    return this._videoThumbnails ?? this.model?.video_thumbnails_enabled ?? true;
  }

  @action
  async toggleFlag(flag) {
    const current = flag.config_value;
    const newValue = current === "true" ? "false" : "true";
    try {
      await ajax(`/admin/plugins/domniq-mobile-app/features/flags.json`, {
        type: "PUT",
        data: {
          flags: [{ config_key: flag.config_key, config_value: newValue }],
        },
      });
      const updated = this.computedFlags.map((f) =>
        f.id === flag.id ? { ...f, config_value: newValue } : f
      );
      this.flags = updated;
      this.toasts.success({
        data: { message: i18n("domniq_app.admin.features.saved") },
        duration: 2000,
      });
    } catch (e) {
      popupAjaxError(e);
    }
  }

  @action
  async updateFlagValue(flag, event) {
    const newValue = event.target.value;
    const updated = this.computedFlags.map((f) =>
      f.id === flag.id ? { ...f, config_value: newValue } : f
    );
    this.flags = updated;
    try {
      await ajax(`/admin/plugins/domniq-mobile-app/features/flags.json`, {
        type: "PUT",
        data: {
          flags: [{ config_key: flag.config_key, config_value: newValue }],
        },
      });
      this.toasts.success({
        data: { message: i18n("domniq_app.admin.features.saved") },
        duration: 2000,
      });
    } catch (e) {
      popupAjaxError(e);
    }
  }

  @action
  async toggleVideoThumbnails() {
    const newValue = !this.videoThumbnailsEnabled;
    try {
      await ajax(`/admin/plugins/domniq-mobile-app/features/flags.json`, {
        type: "PUT",
        data: { video_thumbnails_enabled: newValue },
      });
      this._videoThumbnails = newValue;
      this.toasts.success({
        data: { message: i18n("domniq_app.admin.features.saved") },
        duration: 2000,
      });
    } catch (e) {
      popupAjaxError(e);
    }
  }
}
