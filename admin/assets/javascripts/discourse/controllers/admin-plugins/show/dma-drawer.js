import { tracked } from "@glimmer/tracking";
import Controller from "@ember/controller";
import { action } from "@ember/object";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";

export default class DmaDrawerController extends Controller {
  @tracked items = null;
  @tracked saving = false;
  @tracked saved = false;

  get computedItems() {
    return this.items ?? this.model?.items ?? [];
  }

  get groupedItems() {
    const items = this.computedItems;
    const groups = {};
    for (const item of items) {
      let parsed;
      try {
        parsed = JSON.parse(item.config_value);
      } catch {
        parsed = {};
      }
      const category = parsed.category || "Other";
      if (!groups[category]) {
        groups[category] = [];
      }
      groups[category].push({ ...item, parsed });
    }
    return groups;
  }

  @action
  async toggleItem(item) {
    try {
      const newEnabled = !item.enabled;
      await ajax(
        `/admin/plugins/domniq-mobile-app/drawer/items/${item.id}.json`,
        {
          type: "PUT",
          data: { item: { enabled: newEnabled } },
        }
      );
      const updated = this.computedItems.map((i) =>
        i.id === item.id ? { ...i, enabled: newEnabled } : i
      );
      this.items = updated;
    } catch (e) {
      popupAjaxError(e);
    }
  }
}
