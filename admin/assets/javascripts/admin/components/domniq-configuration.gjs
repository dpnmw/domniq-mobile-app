import Component from "@glimmer/component";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import DButton from "discourse/components/d-button";
import { i18n } from "discourse-i18n";
import DmaPageLayout from "./dma-page-layout";
import DmaLicenseLock from "./dma-license-lock";

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
  show_developer_branding: {
    label: "Show Developer Branding",
    desc: "When enabled, the \"App Developer\" pill appears on the sidebar and the AppInfo screen.",
    type: "toggle",
  },
};

const SUPPORT_LABELS = {
  support_email: {
    label: "Support Email",
    desc: "The contact email displayed on the in-app Message Us screen.",
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
const KNOWN_SUPPORT_KEYS = new Set(Object.keys(SUPPORT_LABELS));
const KNOWN_LEGAL_KEYS = new Set(Object.keys(LEGAL_LABELS));
const KNOWN_ONBOARDING_KEYS = new Set(Object.keys(ONBOARDING_LABELS));

function getFieldMeta(config) {
  return (
    BRANDING_LABELS[config.config_key] ||
    ABOUT_LABELS[config.config_key] ||
    SUPPORT_LABELS[config.config_key] ||
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

function filterSupport(configs) {
  return configs.filter(
    (c) => c.config_type === "branding" && KNOWN_SUPPORT_KEYS.has(c.config_key)
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
    <DmaPageLayout @titleLabel="domniq_app.admin.configuration.title" @descriptionLabel="domniq_app.admin.configuration.description">
      <:icon>
        <svg viewBox="0 -960 960 960" width="24" height="24" fill="white">
          <path d="M479.99-689.33q15.01 0 25.18-10.16 10.16-10.15 10.16-25.17 0-15.01-10.15-25.17Q495.02-760 480.01-760q-15.01 0-25.18 10.15-10.16 10.16-10.16 25.17 0 15.01 10.15 25.18 10.16 10.17 25.17 10.17Zm-33.32 324.66h66.66V-612h-66.66v247.33ZM80-80v-733.33q0-27 19.83-46.84Q119.67-880 146.67-880h666.66q27 0 46.84 19.83Q880-840.33 880-813.33v506.66q0 27-19.83 46.84Q840.33-240 813.33-240H240L80-80Z" />
        </svg>
      </:icon>
      <:content>

      {{! ── App Branding ── }}
      <div class="dma-card dma-card--branding">
        <div class="dma-card__body">
          <h3 class="dma-card__heading"><span class="dma-card__heading-icon"><svg viewBox="0 -960 960 960"><path d="M480-80q-82 0-155-31.5t-127.5-86Q143-252 111.5-325T80-480q0-83 31.5-155.5t86-127Q252-817 325-848.5T480-880q83 0 155.5 31.5t127 86q54.5 54.5 86 127T880-480q0 82-31.5 155t-86 127.5q-54.5 54.5-127 86T480-80Z"/></svg></span>App Branding</h3>
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
      <div class="dma-card dma-card--community {{if @controller.isLocked 'dma-card--locked'}}">
        <div class="dma-card__body">
          <h3 class="dma-card__heading"><span class="dma-card__heading-icon"><svg viewBox="0 -960 960 960"><path d="M440-280h80v-240h-80v240Zm40-320q17 0 28.5-11.5T520-640q0-17-11.5-28.5T480-680q-17 0-28.5 11.5T440-640q0 17 11.5 28.5T480-600ZM480-80q-83 0-156-31.5T197-197q-54-54-85.5-127T80-480q0-83 31.5-156T197-763q54-54 127-85.5T480-880q83 0 156 31.5T763-763q54 54 85.5 127T880-480q0 83-31.5 156T763-197q-54 54-127 85.5T480-80Z"/></svg></span>About Screen</h3>
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
        {{#if @controller.isLocked}}<DmaLicenseLock />{{/if}}
      </div>

      {{! ── Support ── }}
      <div class="dma-card dma-card--support">
        <div class="dma-card__body">
          <h3 class="dma-card__heading"><span class="dma-card__heading-icon"><svg viewBox="0 -960 960 960"><path d="M478-240q21 0 35.5-14.5T528-290q0-21-14.5-35.5T478-340q-21 0-35.5 14.5T428-290q0 21 14.5 35.5T478-240Zm-36-154h74q0-33 7.5-52t42.5-52q26-26 41-49.5t15-56.5q0-56-41-86t-97-30q-57 0-92.5 30T342-618l66 26q5-18 22.5-39t53.5-21q32 0 48 17.5t16 38.5q0 20-12 37.5T506-526q-44 39-54 59t-10 73ZM480-80q-83 0-156-31.5T197-197q-54-54-85.5-127T80-480q0-83 31.5-156T197-763q54-54 127-85.5T480-880q83 0 156 31.5T763-763q54 54 85.5 127T880-480q0 83-31.5 156T763-197q-54 54-127 85.5T480-80Z"/></svg></span>Support</h3>
          <p class="dma-card__description">Contact details shown in the Message Us screen.</p>
          <div class="dma-fields">
            {{#each (filterSupport @controller.computedConfigs) as |config|}}
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

      {{! ── Onboarding ── }}
      <div class="dma-card dma-card--playground {{if @controller.isLocked 'dma-card--locked'}}">
        <div class="dma-card__body">
          <h3 class="dma-card__heading"><span class="dma-card__heading-icon"><svg viewBox="0 -960 960 960"><path d="M200-120q-33 0-56.5-23.5T120-200v-560q0-33 23.5-56.5T200-840h560q33 0 56.5 23.5T840-760v560q0 33-23.5 56.5T760-120H200Zm0-80h560v-560H200v560Zm40-80h480L570-480 450-320l-90-120-120 160Z"/></svg></span>Onboarding Slides</h3>
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
        {{#if @controller.isLocked}}<DmaLicenseLock />{{/if}}
      </div>

      {{! ── Legal Links ── }}
      <div class="dma-card dma-card--legal">
        <div class="dma-card__body">
          <h3 class="dma-card__heading"><span class="dma-card__heading-icon"><svg viewBox="0 -960 960 960"><path d="M480-80q-139.67-35-229.83-161.5Q160-368.67 160-520.67v-240l320-120 320 120v240q0 152-90.17 278.5Q619.67-115.67 480-80.67Z"/></svg></span>Legal Links</h3>
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
          @label="domniq_app.admin.configuration.discard"
          @icon="arrow-rotate-left"
          {{on "click" @controller.discard}}
          class="btn-default"
        />
        <DButton
          @label="domniq_app.admin.configuration.save"
          @icon="check"
          @disabled={{@controller.saving}}
          {{on "click" @controller.save}}
          class="btn-primary"
        />
      </div>
      </:content>
    </DmaPageLayout>
  </template>
}
