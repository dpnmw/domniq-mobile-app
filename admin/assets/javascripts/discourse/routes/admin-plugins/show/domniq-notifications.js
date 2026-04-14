import DiscourseRoute from "discourse/routes/discourse";

export default class DomniqNotificationsRoute extends DiscourseRoute {
  model() {
    return { subscriptions: [] };
  }
}
