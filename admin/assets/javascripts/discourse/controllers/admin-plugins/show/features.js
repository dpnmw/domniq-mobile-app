import { tracked } from "@glimmer/tracking";
import Controller from "@ember/controller";
import { action } from "@ember/object";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";

export default class FeaturesController extends Controller {
  @tracked flags = null;
  @tracked saving = false;
  @tracked saved = false;

  get computedFlags() {
    return this.flags ?? this.model?.flags ?? [];
  }

  @tracked _videoThumbnails = null;

  get videoThumbnailsEnabled() {
    return this._videoThumbnails ?? this.model?.video_thumbnails_enabled ?? true;
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
    } catch (e) {
      popupAjaxError(e);
    }
  }

  @action
  updateFlagValue(flag, event) {
    const updated = this.computedFlags.map((f) =>
      f.id === flag.id ? { ...f, config_value: event.target.value } : f
    );
    this.flags = updated;
    this.saved = false;
  }

  @action
  async toggleFlag(flag) {
    const current = flag.config_value;
    const newValue = current === "true" ? "false" : "true";
    try {
      await ajax(`/admin/plugins/domniq-mobile-app/features/flags.json`, {
        type: "PUT",
        data: {
          flags: [
            { config_key: flag.config_key, config_value: newValue },
          ],
        },
      });
      const updated = this.computedFlags.map((f) =>
        f.id === flag.id ? { ...f, config_value: newValue } : f
      );
      this.flags = updated;
    } catch (e) {
      popupAjaxError(e);
    }
  }

  @action
  discard() {
    this.flags = null;
    this.saved = false;
  }

  @action
  async save() {
    this.saving = true;
    this.saved = false;
    try {
      const flagData = this.computedFlags.map((f) => ({
        config_key: f.config_key,
        config_value: f.config_value,
      }));
      await ajax(`/admin/plugins/domniq-mobile-app/features/flags.json`, {
        type: "PUT",
        data: { flags: flagData },
      });
      this.saved = true;
    } catch (e) {
      popupAjaxError(e);
    } finally {
      this.saving = false;
    }
  }
}
