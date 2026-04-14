import Component from "@glimmer/component";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import DButton from "discourse/components/d-button";
import DPageSubheader from "discourse/components/d-page-subheader";
import formatDate from "discourse/helpers/format-date";
import { i18n } from "discourse-i18n";

export default class DomniqLanguage extends Component {
  <template>
    <section class="domniq-admin">
      <DPageSubheader
        @titleLabel={{i18n "domniq_app.admin.language.title"}}
        @descriptionLabel={{i18n "domniq_app.admin.language.description"}}
      />

      <div class="domniq-admin__section">
        <DButton
          @label="domniq_app.admin.language.export_defaults"
          @icon="download"
          @href="/admin/plugins/domniq/language/export"
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
    </section>
  </template>
}
