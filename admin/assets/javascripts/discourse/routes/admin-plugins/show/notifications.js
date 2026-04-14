import DiscourseRoute from "discourse/routes/discourse";

export default class NotificationsRoute extends DiscourseRoute {
  model() {
    return { subscriptions: [] };
  }
}
