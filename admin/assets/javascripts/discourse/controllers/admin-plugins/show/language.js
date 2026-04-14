import { tracked } from "@glimmer/tracking";
import Controller from "@ember/controller";
import { action } from "@ember/object";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";

export default class LanguageController extends Controller {
  @tracked locales = null;

  get computedLocales() {
    return this.locales ?? this.model?.locales ?? [];
  }

  @action
  async deleteLocale(locale) {
    try {
      await ajax(
        `/admin/plugins/domniq-mobile-app/language/locales/${locale.id}.json`,
        { type: "DELETE" }
      );
      this.locales = this.computedLocales.filter((l) => l.id !== locale.id);
    } catch (e) {
      popupAjaxError(e);
    }
  }
}
