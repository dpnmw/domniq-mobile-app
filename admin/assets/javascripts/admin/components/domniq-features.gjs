import Component from "@glimmer/component";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import DButton from "discourse/components/d-button";
import { i18n } from "discourse-i18n";
import DmaPageLayout from "./dma-page-layout";

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
  replyMode: {
    label: "Reply Mode",
    desc: "Reply experience: 'sheet' for inline bottom sheet, 'fullscreen' for full-screen reply",
    type: "select",
    options: ["sheet", "fullscreen"],
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
    <DmaPageLayout @title="Features" @subtitle="Toggle feature flags like post participants, story layout, reply mode, and video thumbnails.">
      <:icon>
        <svg viewBox="0 -960 960 960" width="24" height="24" fill="white">
          <path d="M446.67-120v-280L249.33-202.33l-47-47L400-446.67H120v-66.66h280.67l-198.34-198 47-47 197.34 197.66V-840h66.66v280l198-198.33 47 47-198.33 198h280v66.66H560.67l197.66 197.34-47 47-198-198.34V-120h-66.66Z" />
        </svg>
      </:icon>

      {{! ── Feature Flags Card ── }}
      <div class="dma-card dma-card--features">
        <div class="dma-card__body">
          <h3 class="dma-card__heading">Feature Flags</h3>
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
      </div>

      {{! ── Video Thumbnails Card ── }}
      <div class="dma-card dma-card--branding">
        <div class="dma-card__body">
          <h3 class="dma-card__heading">Video Thumbnails</h3>
          <p class="dma-card__description">Automatically set video poster thumbnails as topic images for mobile app video uploads.</p>

          <div class="dma-flag-row">
            <div class="dma-flag-row__info">
              <span class="dma-flag-row__key">Video Thumbnails Enabled</span>
              <span class="dma-flag-row__desc">Managed via Site Settings (domniq_app_video_thumbnails_enabled)</span>
            </div>
            <div class="dma-flag-row__control">
              <span class="dma-drawer-item__badge {{if @controller.videoThumbnailsEnabled 'dma-drawer-item__badge--gated' 'dma-drawer-item__badge--coming-soon'}}">
                {{if @controller.videoThumbnailsEnabled "Enabled" "Disabled"}}
              </span>
            </div>
          </div>
        </div>
      </div>

      {{! ── Save ── }}
      <div class="dma-save-row">
        <DButton
          @label="domniq_app.admin.features.save"
          @icon="check"
          @disabled={{@controller.saving}}
          {{on "click" @controller.save}}
          class="btn-primary"
        />
        {{#if @controller.saved}}
          <span class="dma-saved-text">{{i18n "domniq_app.admin.features.saved"}}</span>
        {{/if}}
      </div>
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
