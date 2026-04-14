import Component from "@glimmer/component";
import { on } from "@ember/modifier";
import DButton from "discourse/components/d-button";
import { i18n } from "discourse-i18n";
import DmaPageLayout from "./dma-page-layout";

export default class DomniqLicensing extends Component {
  <template>
    <DmaPageLayout @titleLabel="domniq_app.admin.licensing.title" @descriptionLabel="domniq_app.admin.licensing.description">
      <:icon>
        <svg viewBox="0 -960 960 960" width="24" height="24" fill="white">
          <path d="M480-80.67q-139.67-35-229.83-161.5Q160-368.67 160-520.67v-240l320-120 320 120v240q0 152-90.17 278.5Q619.67-115.67 480-80.67Zm0-69.33q111.33-36.33 182.33-139.67 71-103.33 71-231v-193.66L480-809.67l-253.33 95.34v193.66q0 127.67 71 231Q368.67-186.33 480-150Z" />
        </svg>
      </:icon>
      <:content>

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
      </:content>
    </DmaPageLayout>
  </template>
}
