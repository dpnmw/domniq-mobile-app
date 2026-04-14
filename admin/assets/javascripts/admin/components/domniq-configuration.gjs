import Component from "@glimmer/component";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import DButton from "discourse/components/d-button";
import DPageSubheader from "discourse/components/d-page-subheader";
import { i18n } from "discourse-i18n";

const BRANDING_LABELS = {
  app_name: { label: "App Name", desc: "The display name shown across the mobile app and app stores." },
  app_tagline: { label: "Tagline", desc: "A short description shown below the app name on the welcome and about screens." },
  color_default_style: {
    label: "Color Style",
    desc: "The default color palette applied to the app's UI elements, buttons, and accents.",
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
  deep_link_scheme: { label: "Deep Link Scheme", desc: "URL scheme used to open links directly in the app (e.g. domniq)." },
};

const ABOUT_LABELS = {
  use_site_branding: {
    label: "Use Discourse Site Branding",
    desc: "When enabled, the app pulls the site name, description, and logo from your Discourse site instead of the app defaults.",
    type: "toggle",
  },
};

const LEGAL_LABELS = {
  tos_topic_id: { label: "Terms of Service", desc: "The Discourse topic ID that contains your Terms of Service content." },
  privacy_topic_id: { label: "Privacy Policy", desc: "The Discourse topic ID that contains your Privacy Policy content." },
  faq_topic_id: { label: "FAQ", desc: "The Discourse topic ID that contains your FAQ and community guidelines." },
};

const ONBOARDING_LABELS = {
  slide_1_title: { label: "Slide 1 Title", desc: "Heading for the first onboarding slide." },
  slide_1_description: { label: "Slide 1 Description", desc: "Body text for the first onboarding slide." },
  slide_2_title: { label: "Slide 2 Title", desc: "Heading for the second onboarding slide." },
  slide_2_description: { label: "Slide 2 Description", desc: "Body text for the second onboarding slide." },
  slide_3_title: { label: "Slide 3 Title", desc: "Heading for the third onboarding slide." },
  slide_3_description: { label: "Slide 3 Description", desc: "Body text for the third onboarding slide." },
};

// Only show fields we have labels for — filters out stale DB rows
const KNOWN_BRANDING_KEYS = new Set(Object.keys(BRANDING_LABELS));
const KNOWN_ABOUT_KEYS = new Set(Object.keys(ABOUT_LABELS));
const KNOWN_LEGAL_KEYS = new Set(Object.keys(LEGAL_LABELS));
const KNOWN_ONBOARDING_KEYS = new Set(Object.keys(ONBOARDING_LABELS));

function getFieldMeta(config) {
  return (
    BRANDING_LABELS[config.config_key] ||
    ABOUT_LABELS[config.config_key] ||
    LEGAL_LABELS[config.config_key] ||
    ONBOARDING_LABELS[config.config_key] ||
    { label: config.config_key, desc: "" }
  );
}

function isSelectField(config) {
  return getFieldMeta(config).type === "select";
}

function isToggleField(config) {
  return getFieldMeta(config).type === "toggle";
}

function isToggleOn(config) {
  return config.config_value === "true";
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

function getFieldDesc(config) {
  return getFieldMeta(config).desc || "";
}

function filterBranding(configs) {
  return configs.filter(
    (c) => c.config_type === "branding" && KNOWN_BRANDING_KEYS.has(c.config_key)
  );
}

function filterAbout(configs) {
  return configs.filter(
    (c) => c.config_type === "branding" && KNOWN_ABOUT_KEYS.has(c.config_key)
  );
}

function filterLegal(configs) {
  return configs.filter(
    (c) => c.config_type === "legal" && KNOWN_LEGAL_KEYS.has(c.config_key)
  );
}

function filterOnboarding(configs) {
  return configs.filter(
    (c) => c.config_type === "onboarding" && KNOWN_ONBOARDING_KEYS.has(c.config_key)
  );
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
          <p class="dma-card__description">Identity, appearance, and behavior of the mobile app.</p>
          <div class="dma-fields">
            {{#each (filterBranding @controller.computedConfigs) as |config|}}
              <div class="dma-row">
                <div class="dma-row__label">
                  <span class="dma-row__title">{{getFieldLabel config}}</span>
                  <span class="dma-row__desc">{{getFieldDesc config}}</span>
                </div>
                <div class="dma-row__control">
                  {{#if (isToggleField config)}}
                    <label class="dma-toggle">
                      <input
                        type="checkbox"
                        checked={{isToggleOn config}}
                        {{on "change" (fn @controller.toggleConfigValue config)}}
                      />
                      <span class="dma-toggle__track"></span>
                    </label>
                  {{else if (isSelectField config)}}
                    <select class="dma-field__select" {{on "change" (fn @controller.updateValue config)}}>
                      {{#each (getSelectOptions config) as |opt|}}
                        <option value={{opt.value}} selected={{isSelected config.config_value opt.value}}>{{opt.label}}</option>
                      {{/each}}
                    </select>
                  {{else}}
                    <input type="text" value={{config.config_value}} class="dma-field__input" {{on "input" (fn @controller.updateValue config)}} />
                  {{/if}}
                </div>
              </div>
            {{/each}}
          </div>
        </div>
      </div>

      {{! ── About Screen ── }}
      <div class="dma-card dma-card--community">
        <div class="dma-card__body">
          <h3 class="dma-card__heading">About Screen</h3>
          <p class="dma-card__description">Controls what appears on the app's About page.</p>
          <div class="dma-fields">
            {{#each (filterAbout @controller.computedConfigs) as |config|}}
              <div class="dma-row">
                <div class="dma-row__label">
                  <span class="dma-row__title">{{getFieldLabel config}}</span>
                  <span class="dma-row__desc">{{getFieldDesc config}}</span>
                </div>
                <div class="dma-row__control">
                  <label class="dma-toggle">
                    <input
                      type="checkbox"
                      checked={{isToggleOn config}}
                      {{on "change" (fn @controller.toggleConfigValue config)}}
                    />
                    <span class="dma-toggle__track"></span>
                  </label>
                </div>
              </div>
            {{/each}}
          </div>
        </div>
      </div>

      {{! ── Onboarding ── }}
      <div class="dma-card dma-card--playground">
        <div class="dma-card__body">
          <h3 class="dma-card__heading">Onboarding Slides</h3>
          <p class="dma-card__description">Welcome screen carousel shown to new users before they sign in.</p>
          <div class="dma-fields">
            {{#each (filterOnboarding @controller.computedConfigs) as |config|}}
              <div class="dma-row">
                <div class="dma-row__label">
                  <span class="dma-row__title">{{getFieldLabel config}}</span>
                  <span class="dma-row__desc">{{getFieldDesc config}}</span>
                </div>
                <div class="dma-row__control">
                  {{#if (isDescriptionField config)}}
                    <textarea class="dma-field__input dma-field__textarea" {{on "input" (fn @controller.updateValue config)}}>{{config.config_value}}</textarea>
                  {{else}}
                    <input type="text" value={{config.config_value}} class="dma-field__input" {{on "input" (fn @controller.updateValue config)}} />
                  {{/if}}
                </div>
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
          <div class="dma-fields">
            {{#each (filterLegal @controller.computedConfigs) as |config|}}
              <div class="dma-row">
                <div class="dma-row__label">
                  <span class="dma-row__title">{{getFieldLabel config}}</span>
                  <span class="dma-row__desc">{{getFieldDesc config}}</span>
                </div>
                <div class="dma-row__control">
                  <input type="text" value={{config.config_value}} class="dma-field__input" {{on "input" (fn @controller.updateValue config)}} />
                </div>
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
