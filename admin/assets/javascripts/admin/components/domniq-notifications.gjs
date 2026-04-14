import Component from "@glimmer/component";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import DButton from "discourse/components/d-button";
import avatar from "discourse/helpers/avatar";
import formatDate from "discourse/helpers/format-date";
import { i18n } from "discourse-i18n";
import DmaPageLayout from "./dma-page-layout";

export default class DomniqNotifications extends Component {
  <template>
    <DmaPageLayout @titleLabel="domniq_app.admin.notifications.title" @descriptionLabel="domniq_app.admin.notifications.description">
      <:icon>
        <svg viewBox="0 -960 960 960" width="24" height="24" fill="white">
          <path d="M518.33-501.33ZM480-80q-33 0-56.5-23.5T400-160h160q0 33-23.5 56.5T480-80ZM160-200v-66.67h80v-296q0-83.66 49.67-149.5Q339.33-778 420-796v-24q0-25 17.5-42.5T480-880q25 0 42.5 17.5T540-820v24q31 7 57.5 21.83 26.5 14.84 48.17 35.5l-48.34 49q-23-21-53.33-33.66Q513.67-736 480-736q-72 0-122.67 50.67-50.66 50.66-50.66 122.66v296H800V-200H160Z" />
        </svg>
      </:icon>
      <:content>

      <div class="dma-card dma-card--community">
        <div class="dma-card__body">
          <h3 class="dma-card__heading"><span class="dma-card__heading-icon"><svg viewBox="0 -960 960 960"><path d="M160-200v-66.67h80v-296q0-83.66 49.67-149.5Q339.33-778 420-796v-24q0-25 17.5-42.5T480-880q25 0 42.5 17.5T540-820v24q31 7 57.5 21.83 26.5 14.84 48.17 35.5l-48.34 49q-23-21-53.33-33.66Q513.67-736 480-736q-72 0-122.67 50.67-50.66 50.66-50.66 122.66v296H800V-200H160Z"/></svg></span>Registered Devices</h3>
          <p class="dma-card__description">Devices registered for push notifications via Expo.</p>

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
        </div>
      </div>
      </:content>
    </DmaPageLayout>
  </template>
}
