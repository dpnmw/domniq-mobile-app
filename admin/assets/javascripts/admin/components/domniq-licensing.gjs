import Component from "@glimmer/component";
import { on } from "@ember/modifier";
import DButton from "discourse/components/d-button";
import DPageSubheader from "discourse/components/d-page-subheader";
import { i18n } from "discourse-i18n";

export default class DomniqLicensing extends Component {
  <template>
    <section class="domniq-admin">
      <DPageSubheader
        @titleLabel={{i18n "domniq_app.admin.licensing.title"}}
        @descriptionLabel={{i18n "domniq_app.admin.licensing.description"}}
      />

      <div class="domniq-admin__section">
        <div class="domniq-admin__form">
          <div class="form-row">
            <label>{{i18n "domniq_app.admin.licensing.status"}}</label>
            <span>
              {{#if @controller.isLicensed}}
                <span class="badge badge-notification">{{i18n
                    "domniq_app.admin.licensing.active"
                  }}</span>
              {{else}}
                <span>{{i18n "domniq_app.admin.licensing.inactive"}}</span>
              {{/if}}
            </span>
          </div>

          {{#unless @controller.isLicensed}}
            <div class="form-row">
              <label>{{i18n "domniq_app.admin.licensing.license_key"}}</label>
              <input
                type="text"
                value={{@controller.licenseKey}}
                {{on "input" @controller.updateLicenseKey}}
                placeholder="XXXX-XXXX-XXXX-XXXX"
              />
            </div>

            <DButton
              @label="domniq_app.admin.licensing.activate"
              @icon="key"
              {{on "click" @controller.activateLicense}}
              class="btn-primary"
            />
          {{/unless}}

          <DButton
            @label="domniq_app.admin.licensing.check"
            @icon="rotate"
            {{on "click" @controller.checkLicense}}
            class="btn-default"
          />
        </div>
      </div>
    </section>
  </template>
}
