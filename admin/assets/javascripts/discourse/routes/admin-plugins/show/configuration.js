import { ajax } from "discourse/lib/ajax";
import DiscourseRoute from "discourse/routes/discourse";

export default class DomniqConfigurationRoute extends DiscourseRoute {
  model() {
    return ajax("/admin/plugins/domniq/configs.json");
  }
}
