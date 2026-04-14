import { tracked } from "@glimmer/tracking";
import Controller from "@ember/controller";
import { action } from "@ember/object";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";

export default class ConfigurationController extends Controller {
  @tracked configs = null;
  @tracked saving = false;
  @tracked saved = false;

  get computedConfigs() {
    return this.configs ?? this.model?.configs ?? [];
  }

  get brandingConfigs() {
    return this.computedConfigs.filter((c) => c.config_type === "branding");
  }

  get legalConfigs() {
    return this.computedConfigs.filter((c) => c.config_type === "legal");
  }

  @action
  updateValue(config, event) {
    config.config_value = event.target.value;
    this.configs = [...this.computedConfigs];
    this.saved = false;
  }

  @action
  async save() {
    this.saving = true;
    this.saved = false;
    try {
      const allConfigs = this.computedConfigs;
      for (const config of allConfigs) {
        await ajax(
          `/admin/plugins/domniq-mobile-app/configs/${config.id}.json`,
          {
            type: "PUT",
            data: {
              config: {
                config_value: config.config_value,
              },
            },
          }
        );
      }
      this.saved = true;
    } catch (e) {
      popupAjaxError(e);
    } finally {
      this.saving = false;
    }
  }
}
