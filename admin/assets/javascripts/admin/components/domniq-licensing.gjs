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
                    placeholder="e.g. a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6"
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

      <div class="dma-card dma-card--branding">
        <div class="dma-card__body">
          <h3 class="dma-card__heading"><span class="dma-card__heading-icon"><svg viewBox="0 -960 960 960"><path d="M440-280h80v-240h-80v240Zm40-320q17 0 28.5-11.5T520-640q0-17-11.5-28.5T480-680q-17 0-28.5 11.5T440-640q0 17 11.5 28.5T480-600ZM480-80q-83 0-156-31.5T197-197q-54-54-85.5-127T80-480q0-83 31.5-156T197-763q54-54 127-85.5T480-880q83 0 156 31.5T763-763q54 54 85.5 127T880-480q0 83-31.5 156T763-197q-54 54-127 85.5T480-80Z"/></svg></span>Install Telemetry</h3>
          <p class="dma-card__description">Anonymous usage data sent weekly to DPN Media Works for license verification and support.</p>

          <div class="dma-fields">
            <div class="dma-row">
              <div class="dma-row__label">
                <span class="dma-row__title">Send Anonymous Install Data</span>
                <span class="dma-row__desc">Shares your site URL, plugin version, and enabled features with DPN Media Works. No user data is collected.</span>
              </div>
              <div class="dma-row__control">
                <label class="dma-toggle">
                  <input
                    type="checkbox"
                    checked={{@controller.telemetryEnabled}}
                    {{on "change" @controller.toggleTelemetry}}
                  />
                  <span class="dma-toggle__track"></span>
                </label>
              </div>
            </div>
          </div>
        </div>
      </div>
      </:content>
    </DmaPageLayout>
  </template>
}
