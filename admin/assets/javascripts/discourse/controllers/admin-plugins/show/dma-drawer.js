import { tracked } from "@glimmer/tracking";
import Controller from "@ember/controller";
import { action } from "@ember/object";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";

export default class DmaDrawerController extends Controller {
  @tracked items = null;
  @tracked saving = false;
  @tracked saved = false;
  @tracked isLocked = true;
  @tracked forumFeatures = {};

  constructor() {
    super(...arguments);
    this._fetchLicense();
  }

  async _fetchLicense() {
    try {
      const result = await ajax("/admin/plugins/domniq-mobile-app/license/status.json");
      this.isLocked = !result.licensed;
    } catch {
      this.isLocked = true;
    }
  }

  isCategoryLocked(category) {
    return this.isLocked && (category === "Premium" || category === "Admin Dashboard");
  }

  get computedItems() {
    return this.items ?? this.model?.items ?? [];
  }

  get computedForumFeatures() {
    return this.forumFeatures ?? this.model?.forum_features ?? {};
  }

  // True when a drawer item's featureKey requires a forum feature that is
  // currently disabled. Used by the editor to render locked tiles that admins
  // can't toggle on (since the forum doesn't support it).
  forumFeatureDisabled(featureKey) {
    if (!featureKey) return false;
    const features = this.model?.forum_features ?? {};
    // Undefined keys (features we don't gate on) default to available.
    return features[featureKey] === false;
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
