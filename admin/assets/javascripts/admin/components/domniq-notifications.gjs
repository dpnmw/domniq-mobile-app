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
    <DmaPageLayout
      @titleLabel="domniq_app.admin.notifications.title"
      @descriptionLabel="domniq_app.admin.notifications.description"
    >
      <:icon>
        <svg viewBox="0 -960 960 960" width="24" height="24" fill="white">
          <path d="M518.33-501.33ZM480-80q-33 0-56.5-23.5T400-160h160q0 33-23.5 56.5T480-80ZM160-200v-66.67h80v-296q0-83.66 49.67-149.5Q339.33-778 420-796v-24q0-25 17.5-42.5T480-880q25 0 42.5 17.5T540-820v24q31 7 57.5 21.83 26.5 14.84 48.17 35.5l-48.34 49q-23-21-53.33-33.66Q513.67-736 480-736q-72 0-122.67 50.67-50.66 50.66-50.66 122.66v296H800V-200H160Z" />
        </svg>
      </:icon>
      <:content>

        {{! Push toggle }}
        <div class="dma-card dma-card--features">
          <div class="dma-card__body">
            <h3 class="dma-card__heading">Push Notifications</h3>
            <p class="dma-card__description">Enable or disable push notifications for the mobile app via Expo.</p>
            <div class="dma-fields">
              <div class="dma-row">
                <div class="dma-row__label">
                  <span class="dma-row__title">Push Notifications Enabled</span>
                  <span class="dma-row__desc">When enabled, the app can send push notifications to registered devices.</span>
                </div>
                <div class="dma-row__control">
                  <label class="dma-toggle">
                    <input
                      type="checkbox"
                      checked={{@controller.pushNotificationsEnabled}}
                      {{on "change" @controller.togglePushNotifications}}
                    />
                    <span class="dma-toggle__track"></span>
                  </label>
                </div>
              </div>
            </div>
          </div>
        </div>

        {{! Stats }}
        <div class="dma-card dma-card--community">
          <div class="dma-card__body">
            <h3 class="dma-card__heading">Registered Devices</h3>
            <div class="dma-device-stats">
              <div class="dma-device-stat">
                <div class="dma-device-stat__icon dma-device-stat__icon--total">
                  <svg viewBox="0 -960 960 960" width="24" height="24" fill="white"><path d="M280-40q-33 0-56.5-23.5T200-120v-720q0-33 23.5-56.5T280-920h400q33 0 56.5 23.5T760-840v720q0 33-23.5 56.5T680-40H280Zm0-120v40h400v-40H280Zm0-80h400v-480H280v480Zm0-560h400v-40H280v40Z"/></svg>
                </div>
                <span class="dma-device-stat__value">{{@controller.computedStats.total}}</span>
                <span class="dma-device-stat__label">Total</span>
              </div>
              <div class="dma-device-stat">
                <div class="dma-device-stat__icon dma-device-stat__icon--ios">
                  <svg viewBox="0 0 24 24" width="22" height="22" fill="white"><path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.8-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z"/></svg>
                </div>
                <span class="dma-device-stat__value">{{@controller.computedStats.ios}}</span>
                <span class="dma-device-stat__label">iOS</span>
              </div>
              <div class="dma-device-stat">
                <div class="dma-device-stat__icon dma-device-stat__icon--android">
                  <svg viewBox="0 0 24 24" width="22" height="22" fill="white"><path d="M17.6 11.48l1.74-3c.17-.3.07-.68-.22-.85-.3-.17-.68-.07-.85.22l-1.76 3.06c-1.33-.6-2.81-.95-4.41-.95s-3.09.35-4.42.95L5.87 7.85c-.17-.29-.55-.39-.85-.22-.29.17-.39.55-.22.85l1.74 3C3.69 13.21 1.72 16 1.5 19.5h21c-.22-3.5-2.19-6.29-4.9-8.02zM7 17.25c-.55 0-1-.45-1-1s.45-1 1-1 1 .45 1 1-.45 1-1 1zm10 0c-.55 0-1-.45-1-1s.45-1 1-1 1 .45 1 1-.45 1-1 1z"/></svg>
                </div>
                <span class="dma-device-stat__value">{{@controller.computedStats.android}}</span>
                <span class="dma-device-stat__label">Android</span>
              </div>
            </div>
            <div class="dma-cleanup-row">
              <DButton
                @label="domniq_app.admin.notifications.run_cleanup"
                @icon="trash-can"
                {{on "click" @controller.runCleanup}}
                class="btn-small btn-default"
              />
            </div>
          </div>
        </div>

        {{! Device search }}
        <div class="dma-card dma-card--community">
          <div class="dma-card__body">
            <h3 class="dma-card__heading">Find User Devices</h3>
            <p class="dma-card__description">Search by username to view and manage a user's registered devices.</p>
            <div class="dma-search-row">
              <input
                type="text"
                class="dma-input"
                placeholder={{i18n "domniq_app.admin.notifications.search_placeholder"}}
                value={{@controller.searchUsername}}
                {{on "input" @controller.updateSearchUsername}}
              />
              <DButton
                @label="domniq_app.admin.notifications.search"
                @icon="magnifying-glass"
                {{on "click" @controller.searchDevices}}
                class="btn-primary btn-small"
              />
            </div>

            {{#if @controller.isSearching}}
              <p class="domniq-admin__empty">Searching...</p>
            {{else if @controller.hasSearched}}
              {{#if @controller.searchResults.length}}
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
                    {{#each @controller.searchResults as |sub|}}
                      <tr class="d-admin-row__content">
                        <td class="d-admin-row__overview">
                          <a href="/admin/users/{{sub.user_id}}/{{sub.username}}">
                            {{sub.username}}
                          </a>
                        </td>
                        <td class="d-admin-row__detail">{{sub.platform}}</td>
                        <td class="d-admin-row__detail">{{formatDate sub.created_at}}</td>
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
                <p class="domniq-admin__empty">
                  {{i18n "domniq_app.admin.notifications.no_devices_for_user"}}
                </p>
              {{/if}}
            {{/if}}
          </div>
        </div>

      </:content>
    </DmaPageLayout>
  </template>
}
