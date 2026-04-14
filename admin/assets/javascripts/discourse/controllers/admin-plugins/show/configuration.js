import { tracked } from "@glimmer/tracking";
import Controller from "@ember/controller";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { i18n } from "discourse-i18n";

export default class ConfigurationController extends Controller {
  @service toasts;
  @tracked configs = null;
  @tracked saving = false;

  get computedConfigs() {
    return this.configs ?? this.model?.configs ?? [];
  }

  @action
  updateValue(config, event) {
    config.config_value = event.target.value;
    this.configs = [...this.computedConfigs];
  }

  @action
  toggleConfigValue(config) {
    config.config_value = config.config_value === "true" ? "false" : "true";
    this.configs = [...this.computedConfigs];
  }

  @action
  discard() {
    this.configs = null;
  }

  @action
  async save() {
    this.saving = true;
    try {
      const allConfigs = this.computedConfigs;
      await ajax(`/admin/plugins/domniq-mobile-app/configs/bulk.json`, {
        type: "PUT",
        data: {
          configs: allConfigs.map((c) => ({
            id: c.id,
            config_value: c.config_value,
          })),
        },
      });
      this.toasts.success({
        data: { message: i18n("domniq_app.admin.configuration.saved") },
        duration: 2000,
      });
    } catch (e) {
      popupAjaxError(e);
    } finally {
      this.saving = false;
    }
  }
}
