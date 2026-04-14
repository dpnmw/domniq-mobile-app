import Component from "@glimmer/component";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import DButton from "discourse/components/d-button";
import DPageSubheader from "discourse/components/d-page-subheader";
import { i18n } from "discourse-i18n";

const BRANDING_LABELS = {
  app_name: { label: "App Name", desc: "The display name of the mobile app" },
  app_tagline: { label: "App Tagline", desc: "Shown below the app name" },
  app_scheme: { label: "Deep Link Scheme", desc: "URL scheme for opening links in the app (e.g. domniq)" },
  color_default_style: {
    label: "Default Color Style",
    desc: "The default color palette used across the app",
    type: "select",
    options: [
      { value: "Royal", label: "Island Royal — Classic deep blue", color: "#2B6AFF" },
      { value: "Clover", label: "Emerald Estate — Fresh nature green", color: "#4DAC5C" },
      { value: "Violet", label: "Twilight Purple — Sophisticated and calm", color: "#8A6FD5" },
      { value: "Lily", label: "Tropical Bloom — Vibrant and modern", color: "#F48FB1" },
      { value: "Marigold", label: "Sunset Gold — Warm and vibrant", color: "#CC9619" },
      { value: "Rose", label: "Legacy Red — Bold and powerful", color: "#B03030" },
    ],
  },
};

const LEGAL_LABELS = {
  tos_topic_id: { label: "Terms of Service Topic ID", desc: "Discourse topic ID for Terms of Service" },
  privacy_topic_id: { label: "Privacy Policy Topic ID", desc: "Discourse topic ID for Privacy Policy" },
  faq_topic_id: { label: "FAQ Topic ID", desc: "Discourse topic ID for FAQ" },
};

function getFieldMeta(config) {
  return BRANDING_LABELS[config.config_key] || LEGAL_LABELS[config.config_key] || { label: config.config_key, desc: "" };
}

function isSelectField(config) {
  const meta = getFieldMeta(config);
  return meta.type === "select";
}

function getSelectOptions(config) {
  const meta = getFieldMeta(config);
  return meta.options || [];
}

function isSelected(configValue, optionValue) {
  return configValue === optionValue;
}

export default class DomniqConfiguration extends Component {
  <template>
    <section class="domniq-admin">
      <DPageSubheader
        @titleLabel={{i18n "domniq_app.admin.configuration.title"}}
        @descriptionLabel={{i18n "domniq_app.admin.configuration.description"}}
      />

      {{! ── Branding Card ── }}
      <div class="dma-card dma-card--branding">
        <div class="dma-card__body">
          <h3 class="dma-card__heading">Branding</h3>
          <p class="dma-card__description">App identity and color scheme. These values are used across the mobile app.</p>

          <div class="dma-fields">
            {{#each @controller.brandingConfigs as |config|}}
              <div class="dma-field">
                <span class="dma-field__label">{{getFieldLabel config}}</span>
                {{#if (isSelectField config)}}
                  <select
                    class="dma-field__select"
                    {{on "change" (fn @controller.updateValue config)}}
                  >
                    {{#each (getSelectOptions config) as |opt|}}
                      <option
                        value={{opt.value}}
                        selected={{isSelected config.config_value opt.value}}
                      >{{opt.label}}</option>
                    {{/each}}
                  </select>
                {{else}}
                  <input
                    type="text"
                    value={{config.config_value}}
                    class="dma-field__input"
                    {{on "input" (fn @controller.updateValue config)}}
                  />
                {{/if}}
              </div>
            {{/each}}
          </div>
        </div>
      </div>

      {{! ── Legal Card ── }}
      <div class="dma-card dma-card--legal">
        <div class="dma-card__body">
          <h3 class="dma-card__heading">Legal &amp; Onboarding</h3>
          <p class="dma-card__description">Topic IDs for Terms of Service, Privacy Policy, and FAQ. These are shown during onboarding and in the app settings.</p>

          <div class="dma-fields">
            {{#each @controller.legalConfigs as |config|}}
              <div class="dma-field">
                <span class="dma-field__label">{{getFieldLabel config}}</span>
                <input
                  type="text"
                  value={{config.config_value}}
                  class="dma-field__input"
                  {{on "input" (fn @controller.updateValue config)}}
                />
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

function getFieldLabel(config) {
  const meta = getFieldMeta(config);
  return meta.label;
}
