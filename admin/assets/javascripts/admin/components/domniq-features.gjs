import Component from "@glimmer/component";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import DmaPageLayout from "./dma-page-layout";
import DmaLicenseLock from "./dma-license-lock";

const FLAG_META = {
  showPostParticipants: {
    label: "Show Post Participants",
    desc: "Display participant avatars at the bottom of posts on the home feed",
    type: "boolean",
  },
  storyLayout: {
    label: "Story Layout",
    desc: "Story bar style: 'card' for tall image cards, 'avatar' for circular avatar strip",
    type: "select",
    options: ["card", "avatar"],
  },
};

function getMeta(flag) {
  return FLAG_META[flag.config_key] || { label: flag.config_key, desc: "", type: "text" };
}

function isBooleanFlag(flag) {
  return getMeta(flag).type === "boolean";
}

function isSelectFlag(flag) {
  return getMeta(flag).type === "select";
}

function isTextFlag(flag) {
  const meta = getMeta(flag);
  return meta.type !== "boolean" && meta.type !== "select";
}

function getOptions(flag) {
  return getMeta(flag).options || [];
}

function isBoolTrue(flag) {
  return flag.config_value === "true";
}

export default class DomniqFeatures extends Component {
  <template>
    <DmaPageLayout @titleLabel="domniq_app.admin.features.title" @descriptionLabel="domniq_app.admin.features.description">
      <:icon>
        <svg viewBox="0 -960 960 960" width="24" height="24" fill="white">
          <path d="M446.67-120v-280L249.33-202.33l-47-47L400-446.67H120v-66.66h280.67l-198.34-198 47-47 197.34 197.66V-840h66.66v280l198-198.33 47 47-198.33 198h280v66.66H560.67l197.66 197.34-47 47-198-198.34V-120h-66.66Z" />
        </svg>
      </:icon>
      <:content>

      {{! ── Feature Flags Card ── }}
      <div class="dma-card dma-card--features {{if @controller.isLocked 'dma-card--locked'}}">
        <div class="dma-card__body">
          <h3 class="dma-card__heading"><span class="dma-card__heading-icon"><svg viewBox="0 -960 960 960"><path d="M446.67-120v-280L249.33-202.33l-47-47L400-446.67H120v-66.66h280.67l-198.34-198 47-47 197.34 197.66V-840h66.66v280l198-198.33 47 47-198.33 198h280v66.66H560.67l197.66 197.34-47 47-198-198.34V-120h-66.66Z"/></svg></span>Feature Flags</h3>
          <p class="dma-card__description">Control app behavior and UI layout options. Changes take effect on the next app launch.</p>

          {{#each @controller.computedFlags as |flag|}}
            <div class="dma-flag-row">
              <div class="dma-flag-row__info">
                <span class="dma-flag-row__key">{{getFlagLabel flag}}</span>
                <span class="dma-flag-row__desc">{{getFlagDesc flag}}</span>
              </div>

              <div class="dma-flag-row__control">
                {{#if (isBooleanFlag flag)}}
                  <label class="dma-toggle">
                    <input
                      type="checkbox"
                      checked={{isBoolTrue flag}}
                      {{on "change" (fn @controller.toggleFlag flag)}}
                    />
                    <span class="dma-toggle__track"></span>
                  </label>
                {{else if (isSelectFlag flag)}}
                  <select
                    class="dma-field__select"
                    {{on "change" (fn @controller.updateFlagValue flag)}}
                  >
                    {{#each (getOptions flag) as |opt|}}
                      <option value={{opt}} selected={{eq flag.config_value opt}}>{{opt}}</option>
                    {{/each}}
                  </select>
                {{else}}
                  <input
                    type="text"
                    value={{flag.config_value}}
                    class="dma-field__input"
                    style="max-width: 200px;"
                    {{on "input" (fn @controller.updateFlagValue flag)}}
                  />
                {{/if}}
              </div>
            </div>
          {{/each}}
        </div>
        {{#if @controller.isLocked}}<DmaLicenseLock />{{/if}}
      </div>

      {{! ── Video Thumbnails Card ── }}
      <div class="dma-card dma-card--branding {{if @controller.isLocked 'dma-card--locked'}}">
        <div class="dma-card__body">
          <h3 class="dma-card__heading"><span class="dma-card__heading-icon"><svg viewBox="0 -960 960 960"><path d="M160-160q-33 0-56.5-23.5T80-240v-480q0-33 23.5-56.5T160-800h480q33 0 56.5 23.5T720-720v180l160-160v440L720-420v180q0 33-23.5 56.5T640-160H160Z"/></svg></span>Video Thumbnails</h3>
          <p class="dma-card__description">Automatically set video poster thumbnails as topic images for mobile app video uploads.</p>

          <div class="dma-fields">
            <div class="dma-row">
              <div class="dma-row__label">
                <span class="dma-row__title">Video Thumbnails Enabled</span>
                <span class="dma-row__desc">When enabled, video poster frames are extracted and set as topic thumbnail images.</span>
              </div>
              <div class="dma-row__control">
                <label class="dma-toggle">
                  <input
                    type="checkbox"
                    checked={{@controller.videoThumbnailsEnabled}}
                    {{on "change" @controller.toggleVideoThumbnails}}
                  />
                  <span class="dma-toggle__track"></span>
                </label>
              </div>
            </div>
          </div>
        </div>
        {{#if @controller.isLocked}}<DmaLicenseLock />{{/if}}
      </div>

      </:content>
    </DmaPageLayout>
  </template>
}

function getFlagLabel(flag) {
  return getMeta(flag).label;
}

function getFlagDesc(flag) {
  return getMeta(flag).desc;
}

function eq(a, b) {
  return a === b;
}
