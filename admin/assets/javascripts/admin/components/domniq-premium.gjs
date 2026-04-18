import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { on } from "@ember/modifier";
import APP_VERSION from "./dma-version";
import { htmlSafe } from "@ember/template";
import DmaPageLayout from "./dma-page-layout";

const API_BASE = "https://api.dpnmediaworks.com";

const ICONS = {
  lock: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0110 0v4"/></svg>',
  stats: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="18" y1="20" x2="18" y2="10"/><line x1="12" y1="20" x2="12" y2="4"/><line x1="6" y1="20" x2="6" y2="14"/></svg>',
  list: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="8" y1="6" x2="21" y2="6"/><line x1="8" y1="12" x2="21" y2="12"/><line x1="8" y1="18" x2="21" y2="18"/><line x1="3" y1="6" x2="3.01" y2="6"/><line x1="3" y1="12" x2="3.01" y2="12"/><line x1="3" y1="18" x2="3.01" y2="18"/></svg>',
  about: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>',
};

function iconHtml(name) {
  return htmlSafe(ICONS[name] || "");
}

export default class DomniqPremium extends Component {
  @service toasts;
  @tracked license = null;
  @tracked licenseKey = "";
  @tracked checking = false;
  @tracked activating = false;
  @tracked licenseError = null;

  constructor() {
    super(...arguments);
    this.fetchLicense();
  }

  async fetchLicense() {
    try {
      const { ajax } = await import("discourse/lib/ajax");
      this.license = await ajax("/admin/plugins/domniq-mobile-app/license/status.json");
    } catch {
      this.license = { licensed: false };
    }
  }

  @action
  updateLicenseKey(event) {
    this.licenseKey = event.target.value;
    this.licenseError = null;
  }

  @action
  async activateLicense() {
    if (!this.licenseKey.trim()) return;
    this.activating = true;
    this.licenseError = null;
    try {
      const { ajax } = await import("discourse/lib/ajax");
      const result = await ajax("/admin/plugins/domniq-mobile-app/license/activate.json", {
        type: "POST",
        data: { license_key: this.licenseKey.trim() },
      });
      this.license = result;
      if (result.licensed) {
        this.licenseKey = "";
        this.toasts.success({ data: { message: "Licence activated successfully" }, duration: 3000 });
        window.location.reload();
      }
    } catch (e) {
      const msg = e.jqXHR?.responseJSON?.error || "Activation failed. Please check your licence key.";
      this.licenseError = msg;
      this.toasts.error({ data: { message: msg }, duration: 5000 });
    } finally {
      this.activating = false;
    }
  }

  @action
  async checkLicense() {
    this.checking = true;
    this.licenseError = null;
    try {
      const { ajax } = await import("discourse/lib/ajax");
      this.license = await ajax("/admin/plugins/domniq-mobile-app/license/check.json", { type: "POST" });
      if (this.license.licensed) {
        this.toasts.success({ data: { message: "Licence is valid and active" }, duration: 3000 });
      } else {
        const msg = this.license.error || "Licence is inactive.";
        this.licenseError = msg;
        this.toasts.error({ data: { message: msg }, duration: 5000 });
      }
    } catch {
      this.licenseError = "Unable to verify licence. Please try again later.";
      this.toasts.error({ data: { message: this.licenseError }, duration: 5000 });
      this.license = { licensed: false };
    } finally {
      this.checking = false;
    }
  }

  get isLicensed() {
    return this.license?.licensed === true;
  }

  get isTrial() {
    return this.isLicensed && this.license?.tier === "trial";
  }

  get tierLabel() {
    if (!this.license?.tier) return null;
    return this.license.tier === "trial" ? "Trial" : "Premium";
  }

  get tierClass() {
    if (!this.license?.tier) return "";
    return this.license.tier === "trial" ? "dma-premium__tier--trial" : "dma-premium__tier--premium";
  }

  get statusLabel() {
    if (!this.license) return "Loading...";
    if (this.license.licensed) return "Active";
    return "Inactive";
  }

  get statusClass() {
    if (!this.license) return "";
    return this.license.licensed ? "dma-premium__status--active" : "dma-premium__status--inactive";
  }

  get safeModeUrl() {
    const base = window.location.origin;
    return `${base}/?safe_mode=no_plugins`;
  }

  get telemetryEnabled() {
    return this.license?.telemetry_enabled ?? true;
  }

  get buyUrl() {
    return `${API_BASE}/pay/discourse/domniq-mobile-app`;
  }

  @action
  async toggleTelemetry() {
    const newValue = !this.telemetryEnabled;
    try {
      const { ajax } = await import("discourse/lib/ajax");
      await ajax("/admin/plugins/domniq-mobile-app/license/telemetry.json", {
        type: "PUT",
        data: { telemetry_enabled: newValue },
      });
      this.license = { ...this.license, telemetry_enabled: newValue };
    } catch (e) {
      const { popupAjaxError } = await import("discourse/lib/ajax-error");
      popupAjaxError(e);
    }
  }

  <template>
    <DmaPageLayout @titleLabel="domniq_app.admin.licensing.title" @descriptionLabel="domniq_app.admin.licensing.description">
      <:icon>
        <svg viewBox="0 -960 960 960" width="24" height="24" fill="white">
          <path d="M480-80.67q-139.67-35-229.83-161.5Q160-368.67 160-520.67v-240l320-120 320 120v240q0 152-90.17 278.5Q619.67-115.67 480-80.67Zm0-69.33q111.33-36.33 182.33-139.67 71-103.33 71-231v-193.66L480-809.67l-253.33 95.34v193.66q0 127.67 71 231Q368.67-186.33 480-150Z" />
        </svg>
      </:icon>
      <:content>
        <div class="dma-pcard dma-pcard--settings">
          <div class="dma-pcard__body">
            <h3 class="dma-pcard__heading"><span class="dma-pcard__heading-icon">{{iconHtml "lock"}}</span>Licence Status</h3>
            <p class="dma-pcard__desc">Your current Domniq Mobile App licence status and activation.</p>

            <div class="dma-prow">
              <div class="dma-prow__label">
                <span class="dma-prow__title">Status</span>
                <span class="dma-prow__desc">Whether your licence is currently active</span>
              </div>
              <div class="dma-prow__control">
                <span class="dma-premium__status {{this.statusClass}}">{{this.statusLabel}}</span>
              </div>
            </div>

            {{#if this.isLicensed}}
              {{#if this.tierLabel}}
                <div class="dma-prow">
                  <div class="dma-prow__label">
                    <span class="dma-prow__title">Tier</span>
                    <span class="dma-prow__desc">Your licence plan</span>
                  </div>
                  <div class="dma-prow__control">
                    <span class="dma-premium__tier {{this.tierClass}}">{{this.tierLabel}}</span>
                  </div>
                </div>
              {{/if}}
              {{#if this.license.license_key}}
                <div class="dma-prow">
                  <div class="dma-prow__label">
                    <span class="dma-prow__title">Licence Key</span>
                    <span class="dma-prow__desc">Your activated licence key</span>
                  </div>
                  <div class="dma-prow__control">
                    <span class="dma-premium__key-display">{{this.license.license_key}}</span>
                  </div>
                </div>
              {{/if}}
              {{#if this.license.expires_at}}
                <div class="dma-prow">
                  <div class="dma-prow__label">
                    <span class="dma-prow__title">Expires</span>
                    <span class="dma-prow__desc">When your licence expires</span>
                  </div>
                  <div class="dma-prow__control">
                    <span class="dma-premium__expiry">{{this.license.expires_at}}</span>
                  </div>
                </div>
              {{/if}}
            {{else}}
              <div class="dma-prow">
                <div class="dma-prow__label">
                  <span class="dma-prow__title">Licence Key</span>
                  <span class="dma-prow__desc">Enter your licence key from DPN Media Works</span>
                </div>
                <div class="dma-prow__control">
                  <div class="dma-premium__key-wrapper">
                    <input
                      type="text"
                      value={{this.licenseKey}}
                      {{on "input" this.updateLicenseKey}}
                      placeholder="e.g. a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6"
                      class="dma-pfield__input dma-premium__key-input {{if this.licenseError 'dma-premium__key-input--error'}}"
                    />
                    {{#if this.licenseError}}
                      <span class="dma-premium__hint dma-premium__hint--error">{{this.licenseError}}</span>
                    {{else}}
                      <span class="dma-premium__hint">Enter your licence key and click Activate, or click Check Licence to verify an existing key.</span>
                    {{/if}}
                  </div>
                </div>
              </div>
            {{/if}}

            <div class="dma-premium__actions">
              {{#unless this.isLicensed}}
                <button type="button" class="btn btn-primary btn-small" disabled={{this.activating}} {{on "click" this.activateLicense}}>
                  {{if this.activating "Activating..." "Activate Licence"}}
                </button>
                <a href="{{this.buyUrl}}" target="_blank" rel="noopener noreferrer" class="btn btn-default btn-small">Order Licence</a>
              {{/unless}}
              {{#if this.isTrial}}
                <a href="{{this.buyUrl}}" target="_blank" rel="noopener noreferrer" class="btn btn-primary btn-small">Upgrade Licence</a>
              {{/if}}
              <button type="button" class="btn btn-default btn-small" disabled={{this.checking}} {{on "click" this.checkLicense}}>
                {{if this.checking "Checking..." "Check Licence"}}
              </button>
            </div>
          </div>
        </div>

        {{! ── Early Adopter Pricing ── }}
        {{#unless this.isLicensed}}
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

        <div class="dma-pcard dma-pcard--community">
          <div class="dma-pcard__body">
            <h3 class="dma-pcard__heading"><span class="dma-pcard__heading-icon">{{iconHtml "stats"}}</span>Install Telemetry</h3>
            <p class="dma-pcard__desc">Anonymous usage data sent weekly to DPN Media Works for licence verification and support.</p>

            <div class="dma-prow">
              <div class="dma-prow__label">
                <span class="dma-prow__title">Send Anonymous Install Data</span>
                <span class="dma-prow__desc">Shares your site URL, plugin version, and enabled features with DPN Media Works. No user data is collected.</span>
              </div>
              <div class="dma-prow__control">
                <label class="dma-ptoggle">
                  <input type="checkbox" checked={{this.telemetryEnabled}} {{on "change" this.toggleTelemetry}} />
                  <span class="dma-ptoggle__track"></span>
                </label>
              </div>
            </div>
          </div>
        </div>

        <div class="dma-pcard dma-pcard--community">
          <div class="dma-pcard__body">
            <h3 class="dma-pcard__heading"><span class="dma-pcard__heading-icon">{{iconHtml "list"}}</span>Documentation</h3>
            <div class="dma-premium__links">
              <a href="https://domniq.app" target="_blank" rel="noopener noreferrer" class="dma-premium__link">
                <span>Getting Started</span>
                <span class="dma-premium__arrow">&rarr;</span>
              </a>
              <a href="https://domniq.app" target="_blank" rel="noopener noreferrer" class="dma-premium__link">
                <span>Settings Reference</span>
                <span class="dma-premium__arrow">&rarr;</span>
              </a>
              <a href="https://domniq.app" target="_blank" rel="noopener noreferrer" class="dma-premium__link">
                <span>Changelog</span>
                <span class="dma-premium__arrow">&rarr;</span>
              </a>
            </div>
          </div>
        </div>

        <div class="dma-pcard dma-pcard--support">
          <div class="dma-pcard__body">
            <h3 class="dma-pcard__heading"><span class="dma-pcard__heading-icon">{{iconHtml "about"}}</span>Plugin Info</h3>
            <div class="dma-prow">
              <div class="dma-prow__label"><span class="dma-prow__title">Version</span></div>
              <div class="dma-prow__control"><span>{{APP_VERSION}}</span></div>
            </div>
            <div class="dma-prow">
              <div class="dma-prow__label"><span class="dma-prow__title">Identifier</span></div>
              <div class="dma-prow__control"><span>domniq-mobile-app</span></div>
            </div>
            <div class="dma-prow">
              <div class="dma-prow__label"><span class="dma-prow__title">Safe Mode URL</span></div>
              <div class="dma-prow__control"><code>{{this.safeModeUrl}}</code></div>
            </div>
          </div>
        </div>
      </:content>
    </DmaPageLayout>
  </template>
}
