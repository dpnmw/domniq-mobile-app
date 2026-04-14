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

      <div class="dma-card dma-card--legal">
        <div class="dma-card__body">
          <h3 class="dma-card__heading"><span class="dma-card__heading-icon"><svg viewBox="0 -960 960 960"><path d="M480-80.67q-139.67-35-229.83-161.5Q160-368.67 160-520.67v-240l320-120 320 120v240q0 152-90.17 278.5Q619.67-115.67 480-80.67Z"/></svg></span>License Status</h3>
          <p class="dma-card__description">Your current Domniq Mobile App license status and activation.</p>

          <div class="dma-fields">
            <div class="dma-row">
              <div class="dma-row__label">
                <span class="dma-row__title">Status</span>
                <span class="dma-row__desc">Whether your license is currently active.</span>
              </div>
              <div class="dma-row__control">
                {{#if @controller.isLicensed}}
                  <span class="dma-tile__badge dma-tile__badge--gated">{{i18n "domniq_app.admin.licensing.active"}}</span>
                {{else}}
                  <span class="dma-tile__badge dma-tile__badge--coming-soon">{{i18n "domniq_app.admin.licensing.inactive"}}</span>
                {{/if}}
              </div>
            </div>

            {{#unless @controller.isLicensed}}
              <div class="dma-row">
                <div class="dma-row__label">
                  <span class="dma-row__title">License Key</span>
                  <span class="dma-row__desc">Enter your license key from DPN Media Works.</span>
                </div>
                <div class="dma-row__control">
                  <input
                    type="text"
                    value={{@controller.licenseKey}}
                    {{on "input" @controller.updateLicenseKey}}
                    placeholder="XXXX-XXXX-XXXX-XXXX"
                    class="dma-field__input"
                  />
                </div>
              </div>
            {{/unless}}
          </div>

          <div class="dma-save-row">
            {{#unless @controller.isLicensed}}
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
      </div>
      </:content>
    </DmaPageLayout>
  </template>
}
