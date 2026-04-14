import { ajax } from "discourse/lib/ajax";
import DiscourseRoute from "discourse/routes/discourse";

export default class DomniqDrawerRoute extends DiscourseRoute {
  model() {
    return ajax("/admin/plugins/domniq/drawer/items.json");
  }
}
