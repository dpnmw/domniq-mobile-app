import Component from "@glimmer/component";
import { on } from "@ember/modifier";
import DButton from "discourse/components/d-button";
import { i18n } from "discourse-i18n";
import DmaPageLayout from "./dma-page-layout";

const API_BASE = "https://api.dpnmediaworks.com";

export default class DomniqPremium extends Component {
  get buyUrl() {
    return `${API_BASE}/pay/discourse/domniq-mobile-app`;
  }

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
                  <div class="dma-key-wrapper">
                    <input
                      type="text"
                      value={{@controller.licenseKey}}
                      {{on "input" @controller.updateLicenseKey}}
                      placeholder="e.g. a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6"
                      class="dma-field__input {{if @controller.licenseError 'dma-field__input--error'}}"
                    />
                    {{#if @controller.licenseError}}
                      <span class="dma-key-hint dma-key-hint--error">{{@controller.licenseError}}</span>
                    {{else}}
                      <span class="dma-key-hint">Enter your licence key and click Activate, or click Check Licence to verify an existing key.</span>
                    {{/if}}
                  </div>
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

      {{! ── Early Adopter Pricing ── }}
      {{#unless @controller.isLicensed}}
      <div class="dma-page__licensing">
        <div class="dma-page__licensing-glow"></div>
        <div class="dma-page__licensing-content">
          <div class="dma-page__licensing-header">
            <span class="dma-page__licensing-badge">Early Adopter Pricing</span>
            <h2 class="dma-page__licensing-title">Your Brand. Your App.</h2>
            <p class="dma-page__licensing-subtitle">Get a fully white-labeled native mobile app for your Discourse community — published under your name on both the App Store and Google Play.</p>
          </div>

          <div class="dma-page__licensing-cards">
            <div class="dma-page__licensing-card">
              <div class="dma-page__licensing-card-icon dma-page__licensing-card-icon--ios">
                <svg viewBox="0 0 24 24" width="28" height="28" fill="white"><path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.8-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z"/></svg>
              </div>
              <span class="dma-page__licensing-card-label">iOS App</span>
              <span class="dma-page__licensing-card-detail">App Store</span>
            </div>
            <div class="dma-page__licensing-card-plus">+</div>
            <div class="dma-page__licensing-card">
              <div class="dma-page__licensing-card-icon dma-page__licensing-card-icon--android">
                <svg viewBox="0 0 24 24" width="28" height="28" fill="white"><path d="M17.6 11.48l1.74-3c.17-.3.07-.68-.22-.85-.3-.17-.68-.07-.85.22l-1.76 3.06c-1.33-.6-2.81-.95-4.41-.95s-3.09.35-4.42.95L5.87 7.85c-.17-.29-.55-.39-.85-.22-.29.17-.39.55-.22.85l1.74 3C3.69 13.21 1.72 16 1.5 19.5h21c-.22-3.5-2.19-6.29-4.9-8.02zM7 17.25c-.55 0-1-.45-1-1s.45-1 1-1 1 .45 1 1-.45 1-1 1zm10 0c-.55 0-1-.45-1-1s.45-1 1-1 1 .45 1 1-.45 1-1 1z"/></svg>
              </div>
              <span class="dma-page__licensing-card-label">Android App</span>
              <span class="dma-page__licensing-card-detail">Google Play</span>
            </div>
          </div>

          <div class="dma-page__licensing-price">
            <span class="dma-page__licensing-original">$299</span>
            <div class="dma-page__licensing-sale">
              <span class="dma-page__licensing-currency">$</span>
              <span class="dma-page__licensing-amount">199</span>
              <span class="dma-page__licensing-period">/year</span>
            </div>
            <span class="dma-page__licensing-save">Save $100</span>
          </div>

          <ul class="dma-page__licensing-features">
            <li>Custom app name, icon &amp; branding</li>
            <li>Published on App Store &amp; Google Play under your name</li>
            <li>No DOMNiQ branding anywhere in the app</li>
            <li>Full admin panel control (drawer, config, features)</li>
            <li>Push notifications for your community</li>
            <li>Multi-language support via PO translations</li>
            <li>Ongoing updates &amp; Discourse compatibility</li>
            <li>Priority support from DPN Media Works</li>
          </ul>

          <a href="{{this.buyUrl}}" target="_blank" rel="noopener noreferrer" class="dma-page__licensing-cta">
            Get Your White-Label App
          </a>
          <p class="dma-page__licensing-note">Annual subscription. Billed yearly via PayPal. Cancel anytime.</p>
        </div>
      </div>
      {{/unless}}

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
