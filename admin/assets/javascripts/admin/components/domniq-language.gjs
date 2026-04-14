import Component from "@glimmer/component";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import DButton from "discourse/components/d-button";
import formatDate from "discourse/helpers/format-date";
import { i18n } from "discourse-i18n";
import DmaPageLayout from "./dma-page-layout";

export default class DomniqLanguage extends Component {
  <template>
    <DmaPageLayout @title="Language" @subtitle="Export English defaults as PO files, import translations, and let users switch languages in the app.">
      <:icon>
        <svg viewBox="0 -960 960 960" width="24" height="24" fill="white">
          <path d="M240-289.33 49.33-480 240-670.67 286.67-624l-143 144 143 144L240-289.33Zm174 132.66-64-20 196.67-626.66L610-784 414-156.67Zm306-132.66L673.33-336l143-144-143-144L720-670.67 910.67-480 720-289.33Z" />
        </svg>
      </:icon>

      <div class="domniq-admin__section">
        <DButton
          @label="domniq_app.admin.language.export_defaults"
          @icon="download"
          @href="/admin/plugins/domniq-mobile-app/language/export"
          class="btn-default"
        />
      </div>

      <div class="domniq-admin__section">
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
    </DmaPageLayout>
  </template>
}
