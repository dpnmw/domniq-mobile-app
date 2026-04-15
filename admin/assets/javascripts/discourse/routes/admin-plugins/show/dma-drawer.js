import { ajax } from "discourse/lib/ajax";
import DiscourseRoute from "discourse/routes/discourse";

export default class DmaDrawerRoute extends DiscourseRoute {
  model() {
    return ajax("/admin/plugins/domniq-mobile-app/drawer/items.json");
  }
}
