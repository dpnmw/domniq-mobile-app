import { ajax } from "discourse/lib/ajax";
import DiscourseRoute from "discourse/routes/discourse";

export default class DmaLanguageRoute extends DiscourseRoute {
  model() {
    return ajax("/admin/plugins/domniq-mobile-app/language/locales.json");
  }
}
