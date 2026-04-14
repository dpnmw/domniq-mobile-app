import Component from "@glimmer/component";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import DButton from "discourse/components/d-button";
import DPageSubheader from "discourse/components/d-page-subheader";
import avatar from "discourse/helpers/avatar";
import formatDate from "discourse/helpers/format-date";
import { i18n } from "discourse-i18n";

export default class DomniqNotifications extends Component {
  <template>
    <section class="domniq-admin">
      <DPageSubheader
        @titleLabel={{i18n "domniq_app.admin.notifications.title"}}
        @descriptionLabel={{i18n
          "domniq_app.admin.notifications.description"
        }}
      />

      {{#if @controller.computedSubscriptions.length}}
        <table class="d-admin-table domniq-admin__table">
          <thead>
            <tr>
              <th>{{i18n "domniq_app.admin.notifications.user"}}</th>
              <th>{{i18n "domniq_app.admin.notifications.platform"}}</th>
              <th>{{i18n "domniq_app.admin.notifications.registered"}}</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            {{#each @controller.computedSubscriptions as |sub|}}
              <tr class="d-admin-row__content">
                <td class="d-admin-row__overview">
                  <a
                    href="/admin/users/{{sub.user_id}}/{{sub.username}}"
                    data-user-card={{sub.username}}
                  >
                    {{avatar sub imageSize="small"}}
                    <span>{{sub.username}}</span>
                  </a>
                </td>
                <td class="d-admin-row__detail">{{sub.platform}}</td>
                <td class="d-admin-row__detail">{{formatDate
                    sub.created_at
                  }}</td>
                <td class="d-admin-row__controls">
                  <DButton
                    @label="domniq_app.admin.notifications.test_push"
                    @icon="paper-plane"
                    {{on "click" (fn @controller.sendTestPush sub)}}
                    class="btn-small btn-default"
                  />
                  <DButton
                    @label="domniq_app.admin.notifications.remove"
                    @icon="trash-can"
                    {{on "click" (fn @controller.removeSubscription sub)}}
                    class="btn-small btn-danger"
                  />
                </td>
              </tr>
            {{/each}}
          </tbody>
        </table>
      {{else}}
        <p class="domniq-admin__empty">{{i18n
            "domniq_app.admin.notifications.no_devices"
          }}</p>
      {{/if}}
    </section>
  </template>
}
