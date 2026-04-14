import Component from "@glimmer/component";
import DPageSubheader from "discourse/components/d-page-subheader";
import { i18n } from "discourse-i18n";

export default class DomniqFeatures extends Component {
  <template>
    <section class="domniq-admin">
      <DPageSubheader
        @titleLabel={{i18n "domniq_app.admin.features.title"}}
        @descriptionLabel={{i18n "domniq_app.admin.features.description"}}
      />

      <div class="domniq-admin__section">
        {{#if @model.flags.length}}
          <table class="d-admin-table domniq-admin__table">
            <thead>
              <tr>
                <th>{{i18n "domniq_app.admin.features.flag"}}</th>
                <th>{{i18n "domniq_app.admin.features.value"}}</th>
              </tr>
            </thead>
            <tbody>
              {{#each @model.flags as |flag|}}
                <tr class="d-admin-row__content">
                  <td class="d-admin-row__detail">{{flag.config_key}}</td>
                  <td class="d-admin-row__detail">{{flag.config_value}}</td>
                </tr>
              {{/each}}
            </tbody>
          </table>
        {{else}}
          <p class="domniq-admin__empty">No feature flags configured.</p>
        {{/if}}
      </div>
    </section>
  </template>
}
