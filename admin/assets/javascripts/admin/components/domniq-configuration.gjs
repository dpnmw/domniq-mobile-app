import Component from "@glimmer/component";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import DButton from "discourse/components/d-button";
import DPageSubheader from "discourse/components/d-page-subheader";
import { i18n } from "discourse-i18n";

const BRANDING_LABELS = {
  app_name: { label: "App Name", desc: "Display name of the mobile app" },
  app_tagline: { label: "Tagline", desc: "Shown below the app name" },
  app_scheme: { label: "Deep Link Scheme", desc: "URL scheme for deep links (e.g. domniq)" },
  color_default_style: {
    label: "Color Style",
    desc: "Default color palette",
    type: "select",
    options: [
      { value: "Royal", label: "Royal — Classic deep blue" },
      { value: "Clover", label: "Clover — Fresh nature green" },
      { value: "Violet", label: "Violet — Elegant and calm" },
      { value: "Lily", label: "Lily — Soft and delicate" },
      { value: "Marigold", label: "Marigold — Warm and vibrant" },
      { value: "Rose", label: "Rose — Bold & Passionate" },
    ],
  },
};

const LEGAL_LABELS = {
  tos_topic_id: { label: "Terms of Service", desc: "Topic ID" },
  privacy_topic_id: { label: "Privacy Policy", desc: "Topic ID" },
  faq_topic_id: { label: "FAQ", desc: "Topic ID" },
};

const ONBOARDING_LABELS = {
  slide_1_title: { label: "Slide 1 Title" },
  slide_1_description: { label: "Slide 1 Description" },
  slide_2_title: { label: "Slide 2 Title" },
  slide_2_description: { label: "Slide 2 Description" },
  slide_3_title: { label: "Slide 3 Title" },
  slide_3_description: { label: "Slide 3 Description" },
};

function getFieldMeta(config) {
  return (
    BRANDING_LABELS[config.config_key] ||
    LEGAL_LABELS[config.config_key] ||
    ONBOARDING_LABELS[config.config_key] ||
    { label: config.config_key, desc: "" }
  );
}

function isSelectField(config) {
  return getFieldMeta(config).type === "select";
}

function isDescriptionField(config) {
  return config.config_key.endsWith("_description");
}

function getSelectOptions(config) {
  return getFieldMeta(config).options || [];
}

function isSelected(configValue, optionValue) {
  return configValue === optionValue;
}

function getFieldLabel(config) {
  return getFieldMeta(config).label;
}

export default class DomniqConfiguration extends Component {
  <template>
    <section class="domniq-admin">
      <DPageSubheader
        @titleLabel={{i18n "domniq_app.admin.configuration.title"}}
        @descriptionLabel={{i18n "domniq_app.admin.configuration.description"}}
      />

      {{! ── App Branding ── }}
      <div class="dma-card dma-card--branding">
        <div class="dma-card__body">
          <h3 class="dma-card__heading">App Branding</h3>
          <p class="dma-card__description">Identity and appearance of the mobile app.</p>
          <div class="dma-fields dma-fields--compact">
            {{#each @controller.brandingConfigs as |config|}}
              <div class="dma-field dma-field--inline">
                <span class="dma-field__label">{{getFieldLabel config}}</span>
                {{#if (isSelectField config)}}
                  <select
                    class="dma-field__select"
                    {{on "change" (fn @controller.updateValue config)}}
                  >
                    {{#each (getSelectOptions config) as |opt|}}
                      <option value={{opt.value}} selected={{isSelected config.config_value opt.value}}>{{opt.label}}</option>
                    {{/each}}
                  </select>
                {{else}}
                  <input type="text" value={{config.config_value}} class="dma-field__input" {{on "input" (fn @controller.updateValue config)}} />
                {{/if}}
              </div>
            {{/each}}
          </div>
        </div>
      </div>

      {{! ── About Screen ── }}
      <div class="dma-card dma-card--community">
        <div class="dma-card__body">
          <h3 class="dma-card__heading">About Screen</h3>
          <p class="dma-card__description">Controls what appears on the app's About page. Toggle to pull name, description, and logo from your Discourse site settings instead of the app defaults.</p>
          <div class="dma-fields dma-fields--compact">
            <div class="dma-field dma-field--inline">
              <span class="dma-field__label">Use Discourse Site Branding</span>
              <label class="dma-toggle">
                <input type="checkbox" checked={{@controller.useSiteBranding}} {{on "change" @controller.toggleSiteBranding}} />
                <span class="dma-toggle__track"></span>
              </label>
            </div>
          </div>
          <p class="dma-card__hint">Managed via Site Settings (domniq_app_use_site_branding). When enabled, the app pulls the site name, description, and logo from Discourse's /about page.</p>
        </div>
      </div>

      {{! ── Onboarding ── }}
      <div class="dma-card dma-card--playground">
        <div class="dma-card__body">
          <h3 class="dma-card__heading">Onboarding Slides</h3>
          <p class="dma-card__description">Welcome screen carousel shown to new users before they sign in.</p>
          <div class="dma-fields dma-fields--grid">
            {{#each @controller.onboardingConfigs as |config|}}
              <div class="dma-field">
                <span class="dma-field__label">{{getFieldLabel config}}</span>
                {{#if (isDescriptionField config)}}
                  <textarea class="dma-field__input dma-field__textarea" {{on "input" (fn @controller.updateValue config)}}>{{config.config_value}}</textarea>
                {{else}}
                  <input type="text" value={{config.config_value}} class="dma-field__input" {{on "input" (fn @controller.updateValue config)}} />
                {{/if}}
              </div>
            {{/each}}
          </div>
        </div>
      </div>

      {{! ── Legal Links ── }}
      <div class="dma-card dma-card--legal">
        <div class="dma-card__body">
          <h3 class="dma-card__heading">Legal Links</h3>
          <p class="dma-card__description">Discourse topic IDs shown in the app's Policies section and onboarding disclaimer.</p>
          <div class="dma-fields dma-fields--compact">
            {{#each @controller.legalConfigs as |config|}}
              <div class="dma-field dma-field--inline">
                <span class="dma-field__label">{{getFieldLabel config}}</span>
                <input type="text" value={{config.config_value}} class="dma-field__input" style="max-width: 120px;" {{on "input" (fn @controller.updateValue config)}} />
              </div>
            {{/each}}
          </div>
        </div>
      </div>

      {{! ── Save ── }}
      <div class="dma-save-row">
        <DButton
          @label="domniq_app.admin.configuration.save"
          @icon="check"
          @disabled={{@controller.saving}}
          {{on "click" @controller.save}}
          class="btn-primary"
        />
        {{#if @controller.saved}}
          <span class="dma-saved-text">{{i18n "domniq_app.admin.configuration.saved"}}</span>
        {{/if}}
      </div>
    </section>
  </template>
}
