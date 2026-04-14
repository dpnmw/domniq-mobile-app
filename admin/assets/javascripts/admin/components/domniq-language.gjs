import Component from "@glimmer/component";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import DButton from "discourse/components/d-button";
import formatDate from "discourse/helpers/format-date";
import { i18n } from "discourse-i18n";
import DmaPageLayout from "./dma-page-layout";

export default class DomniqLanguage extends Component {
  <template>
    <DmaPageLayout @titleLabel="domniq_app.admin.language.title" @descriptionLabel="domniq_app.admin.language.description">
      <:icon>
        <svg viewBox="0 -960 960 960" width="24" height="24" fill="white">
          <path d="M240-289.33 49.33-480 240-670.67 286.67-624l-143 144 143 144L240-289.33Zm174 132.66-64-20 196.67-626.66L610-784 414-156.67Zm306-132.66L673.33-336l143-144-143-144L720-670.67 910.67-480 720-289.33Z" />
        </svg>
      </:icon>
      <:content>

      <div class="dma-card dma-card--branding">
        <div class="dma-card__body">
          <h3 class="dma-card__heading"><span class="dma-card__heading-icon"><svg viewBox="0 -960 960 960"><path d="M480-80q-83 0-156-31.5T197-197q-54-54-85.5-127T80-480q0-83 31.5-156T197-763q54-54 127-85.5T480-880q83 0 156 31.5T763-763q54 54 85.5 127T880-480q0 83-31.5 156T763-197q-54 54-127 85.5T480-80Zm-40-82v-78q-33 0-56.5-23.5T360-320v-40L168-552q-3 18-5.5 36t-2.5 36q0 121 79.5 212T440-162Zm276-102q20-22 36-47.5t26.5-53q10.5-27.5 16-56.5t5.5-59q0-98-54.5-179T600-776v16q0 33-23.5 56.5T520-680h-80v80q0 17-11.5 28.5T400-560h-80v80h240q17 0 28.5 11.5T600-440v120h40q26 0 47 15.5t29 40.5Z"/></svg></span>Export Defaults</h3>
          <p class="dma-card__description">Download the English default translation strings as a PO file for translators.</p>
          <div style="margin-top: 0.5rem;">
            <DButton
              @label="domniq_app.admin.language.export_defaults"
              @icon="download"
              @href="/admin/plugins/domniq-mobile-app/language/export"
              class="btn-default"
            />
          </div>
        </div>
      </div>

      <div class="dma-card dma-card--support">
        <div class="dma-card__body">
          <h3 class="dma-card__heading"><span class="dma-card__heading-icon"><svg viewBox="0 -960 960 960"><path d="M240-289.33 49.33-480 240-670.67 286.67-624l-143 144 143 144L240-289.33Zm174 132.66-64-20 196.67-626.66L610-784 414-156.67Zm306-132.66L673.33-336l143-144-143-144L720-670.67 910.67-480 720-289.33Z"/></svg></span>Available Translations</h3>
          <p class="dma-card__description">Uploaded translation files. Users can switch languages within the app.</p>

          {{#if @controller.computedLocales.length}}
            <table class="d-admin-table domniq-admin__table">
              <thead>
                <tr>
                  <th>{{i18n "domniq_app.admin.language.locale"}}</th>
                  <th>{{i18n "domniq_app.admin.language.label"}}</th>
                  <th>{{i18n "domniq_app.admin.language.version"}}</th>
                  <th>{{i18n "domniq_app.admin.language.updated"}}</th>
                  <th></th>
                </tr>
              </thead>
              <tbody>
                {{#each @controller.computedLocales as |locale|}}
                  <tr class="d-admin-row__content">
                    <td class="d-admin-row__detail">{{locale.locale}}</td>
                    <td class="d-admin-row__detail">{{locale.label}}</td>
                    <td class="d-admin-row__detail">v{{locale.version}}</td>
                    <td class="d-admin-row__detail">{{formatDate
                        locale.updated_at
                      }}</td>
                    <td class="d-admin-row__controls">
                      <DButton
                        @label="domniq_app.admin.language.delete_locale"
                        @icon="trash-can"
                        {{on "click" (fn @controller.deleteLocale locale)}}
                        class="btn-small btn-danger"
                      />
                    </td>
                  </tr>
                {{/each}}
              </tbody>
            </table>
          {{else}}
            <p class="domniq-admin__empty">{{i18n
                "domniq_app.admin.language.no_locales"
              }}</p>
          {{/if}}
        </div>
      </div>
      </:content>
    </DmaPageLayout>
  </template>
}
