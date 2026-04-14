import Component from "@glimmer/component";
import DPageSubheader from "discourse/components/d-page-subheader";
import { i18n } from "discourse-i18n";

export default class DomniqDrawerEditor extends Component {
  <template>
    <section class="domniq-admin">
      <DPageSubheader
        @titleLabel={{i18n "domniq_app.admin.drawer.title"}}
        @descriptionLabel={{i18n "domniq_app.admin.drawer.description"}}
      />

      <div class="domniq-admin__section">
        {{#if @model.items.length}}
          <table class="d-admin-table domniq-admin__table">
            <thead>
              <tr>
                <th>{{i18n "domniq_app.admin.drawer.position"}}</th>
                <th>{{i18n "domniq_app.admin.drawer.label"}}</th>
                <th>{{i18n "domniq_app.admin.drawer.visible"}}</th>
              </tr>
            </thead>
            <tbody>
              {{#each @model.items as |item|}}
                <tr class="d-admin-row__content">
                  <td class="d-admin-row__detail">{{item.position}}</td>
                  <td class="d-admin-row__detail">{{item.config_key}}</td>
                  <td class="d-admin-row__detail">{{if
                      item.enabled
                      "Yes"
                      "No"
                    }}</td>
                </tr>
              {{/each}}
            </tbody>
          </table>
        {{else}}
          <p class="domniq-admin__empty">{{i18n
              "domniq_app.admin.drawer.no_items"
            }}</p>
        {{/if}}
      </div>
    </section>
  </template>
}
