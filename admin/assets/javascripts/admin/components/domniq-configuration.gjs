import Component from "@glimmer/component";
import DPageSubheader from "discourse/components/d-page-subheader";
import { i18n } from "discourse-i18n";

export default class DomniqConfiguration extends Component {
  <template>
    <section class="domniq-admin">
      <DPageSubheader
        @titleLabel={{i18n "domniq_app.admin.configuration.title"}}
        @descriptionLabel={{i18n
          "domniq_app.admin.configuration.description"
        }}
      />

      <div class="domniq-admin__section">
        {{#if @model.configs}}
          <table class="d-admin-table domniq-admin__table">
            <thead>
              <tr>
                <th>Type</th>
                <th>Key</th>
                <th>Value</th>
                <th>Enabled</th>
              </tr>
            </thead>
            <tbody>
              {{#each @model.configs as |config|}}
                <tr class="d-admin-row__content">
                  <td class="d-admin-row__detail">{{config.config_type}}</td>
                  <td class="d-admin-row__detail">{{config.config_key}}</td>
                  <td class="d-admin-row__detail">{{config.config_value}}</td>
                  <td class="d-admin-row__detail">{{if
                      config.enabled
                      "Yes"
                      "No"
                    }}</td>
                </tr>
              {{/each}}
            </tbody>
          </table>
        {{else}}
          <p class="domniq-admin__empty">No configuration entries yet.</p>
        {{/if}}
      </div>
    </section>
  </template>
}
