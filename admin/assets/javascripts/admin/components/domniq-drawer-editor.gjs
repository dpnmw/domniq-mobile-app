import Component from "@glimmer/component";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import ICONS from "./domniq-icons";
import DmaPageLayout from "./dma-page-layout";
import DmaLicenseLock from "./dma-license-lock";

const CATEGORY_META = {
  Widgets: {
    color: "#3B82F6",
    cardClass: "dma-card--widgets",
    desc: "Home-screen trending widgets. License-gated; not individually toggleable.",
    iconPath: "M120-520v-320h320v320H120Zm0 400v-320h320v320H120Zm400-400v-320h320v320H520Zm0 400v-320h320v320H520Z",
  },
  Premium: {
    color: "#A358DF",
    cardClass: "dma-card--premium",
    desc: "Premium features and exclusive content for licensed users.",
    iconPath: "M200-120q-33 0-56.5-23.5T120-200v-560q0-33 23.5-56.5T200-840h560q33 0 56.5 23.5T840-760v560q0 33-23.5 56.5T760-120H200Zm0-80h560v-560H200v560Zm40-80h480L570-480 450-320l-90-120-120 160Z",
  },
  Community: {
    color: "#4ECDC4",
    cardClass: "dma-card--community",
    desc: "Social features, leaderboards, and community information.",
    iconPath: "M40-160v-112q0-34 17.5-62.5T104-378q62-31 126-46.5T360-440q66 0 130 15.5T616-378q29 15 46.5 43.5T680-272v112H40Zm720 0v-120q0-44-24.5-84.5T666-434q51 6 96 20.5t84 35.5q36 20 55 44.5t19 53.5v120H760ZM360-480q-66 0-113-47t-47-113q0-66 47-113t113-47q66 0 113 47t47 113q0 66-47 113t-113 47Zm400-160q0 66-47 113t-113 47q-11 0-28-2.5t-28-5.5q27-32 41.5-71t14.5-81q0-42-14.5-81T544-792q14-5 28-6.5t28-1.5q66 0 113 47t47 113Z",
  },
  Settings: {
    color: "#F5A623",
    cardClass: "dma-card--settings",
    desc: "User preferences for appearance, notifications, and device permissions.",
    iconPath: "m370-80-16-128q-13-5-24.5-12T307-235l-119 50L78-375l103-78q-1-7-1-13.5v-27q0-6.5 1-13.5L78-585l110-190 119 50q11-8 23-15t24-12l16-128h220l16 128q13 5 24.5 12t22.5 15l119-50 110 190-103 78q1 7 1 13.5v27q0 6.5-2 13.5l103 78-110 190-118-50q-11 8-23 15t-24 12L590-80H370Zm112-260q58 0 99-41t41-99q0-58-41-99t-99-41q-59 0-99.5 41T342-480q0 58 40.5 99t99.5 41Z",
  },
  Support: {
    color: "#74b9ff",
    cardClass: "dma-card--support",
    desc: "Help resources, developer info, and contact options.",
    iconPath: "M478-240q21 0 35.5-14.5T528-290q0-21-14.5-35.5T478-340q-21 0-35.5 14.5T428-290q0 21 14.5 35.5T478-240Zm-36-154h74q0-33 7.5-52t42.5-52q26-26 41-49.5t15-56.5q0-56-41-86t-97-30q-57 0-92.5 30T342-618l66 26q5-18 22.5-39t53.5-21q32 0 48 17.5t16 38.5q0 20-12 37.5T506-526q-44 39-54 59t-10 73ZM480-80q-83 0-156-31.5T197-197q-54-54-85.5-127T80-480q0-83 31.5-156T197-763q54-54 127-85.5T480-880q83 0 156 31.5T763-763q54 54 85.5 127T880-480q0 83-31.5 156T763-197q-54 54-127 85.5T480-80Z",
  },
  "Admin Dashboard": {
    color: "#EF5350",
    cardClass: "dma-card--admin",
    desc: "Staff-only tools for site analytics, user management, and moderation.",
    iconPath: "M480-80q-139.67-35-229.83-161.5Q160-368.67 160-520.67v-240l320-120 320 120v240q0 152-90.17 278.5Q619.67-115.67 480-80.67Z",
  },
};

const CATEGORY_ORDER = ["Widgets", "Premium", "Community", "Settings", "Support", "Admin Dashboard"];

const LOCKED_CATEGORIES = new Set(["Widgets", "Premium", "Admin Dashboard"]);

// Categories whose items are infrastructure / license-controlled — admins don't
// toggle them on/off in the drawer editor. Only Community items are toggleable:
// those gate the app's rendering when a native forum feature (gamification,
// groups) is either unavailable on the forum or disabled by the admin.
//
// - Premium: rendering is license-driven in the app, not admin-toggled.
// - Admin Dashboard: license + staff gated in the app.
// - Settings: user-owned preferences; surfaced as a visual map only.
// - Support: infrastructure; always shown.
const NON_TOGGLEABLE_CATEGORIES = new Set(["Widgets", "Premium", "Support", "Admin Dashboard", "Settings"]);

// Specific item keys that should never be toggleable, regardless of category.
// - `overview` is the required About Us shortcut in Community.
// - coming-soon items are not toggleable since they don't do anything yet.
const NON_TOGGLEABLE_ITEM_KEYS = new Set(["overview"]);

function isItemToggleable(item) {
  if (!item) return false;
  if (item.parsed?.comingSoon) return false;
  if (NON_TOGGLEABLE_ITEM_KEYS.has(item.config_key)) return false;
  if (item.parsed?.category && NON_TOGGLEABLE_CATEGORIES.has(item.parsed.category)) return false;
  return true;
}

function featureKeyOf(item) {
  return item?.parsed?.featureKey || null;
}

function isFeatureUnavailable(item, forumFeatures) {
  const key = featureKeyOf(item);
  if (!key) return false;
  return forumFeatures?.[key] === false;
}

function featureBadgeText(item, forumFeatures) {
  const key = featureKeyOf(item);
  if (!key) return null;
  const labelMap = {
    gamification: "Gamification",
    groups: "Groups",
  };
  const label = labelMap[key] || key;
  const enabled = forumFeatures?.[key] !== false;
  return `${label} ${enabled ? "Enabled" : "Disabled"}`;
}

function featureBadgeClass(item, forumFeatures) {
  const key = featureKeyOf(item);
  if (!key) return "";
  const enabled = forumFeatures?.[key] !== false;
  return enabled ? "dma-tile__badge--feature-on" : "dma-tile__badge--feature-off";
}

function sortedCategories(groupedItems, isLocked) {
  return CATEGORY_ORDER.filter((cat) => groupedItems[cat]).map((cat) => ({
    name: cat,
    items: groupedItems[cat],
    color: CATEGORY_META[cat]?.color || "#999",
    cardClass: CATEGORY_META[cat]?.cardClass || "",
    desc: CATEGORY_META[cat]?.desc || "",
    iconPath: CATEGORY_META[cat]?.iconPath || "",
    locked: !!isLocked && LOCKED_CATEGORIES.has(cat),
  }));
}

function getIconData(iconName) {
  return ICONS[iconName] || null;
}

function hasIcon(iconName) {
  return !!ICONS[iconName];
}

function getInitial(iconName) {
  if (!iconName) {
    return "?";
  }
  return iconName.charAt(0).toUpperCase();
}

function getIconViewBox(iconName) {
  const icon = getIconData(iconName);
  return icon ? icon.viewBox : "0 0 24 24";
}

function getIconPaths(iconName) {
  const icon = getIconData(iconName);
  return icon ? icon.paths : [];
}

export default class DomniqDrawerEditor extends Component {
  <template>
    <DmaPageLayout @titleLabel="domniq_app.admin.drawer.title" @descriptionLabel="domniq_app.admin.drawer.description">
      <:icon>
        <svg viewBox="0 -960 960 960" width="24" height="24" fill="white">
          <path d="M186.67-120q-27 0-46.84-19.83Q120-159.67 120-186.67v-586.66q0-27 19.83-46.84Q159.67-840 186.67-840h586.66q27 0 46.84 19.83Q840-800.33 840-773.33v586.66q0 27-19.83 46.84Q800.33-120 773.33-120H186.67Zm0-66.67h586.66v-586.66H186.67v586.66ZM480-280q17 0 28.5-11.5T520-320q0-17-11.5-28.5T480-360q-17 0-28.5 11.5T440-320q0 17 11.5 28.5T480-280Zm-160 0q17 0 28.5-11.5T360-320q0-17-11.5-28.5T320-360q-17 0-28.5 11.5T280-320q0 17 11.5 28.5T320-280Zm320 0q17 0 28.5-11.5T680-320q0-17-11.5-28.5T640-360q-17 0-28.5 11.5T600-320q0 17 11.5 28.5T640-280Z" />
        </svg>
      </:icon>
      <:content>

      {{#each (sortedCategories @controller.groupedItems @controller.isLocked) as |group|}}
        <div class="dma-card {{group.cardClass}} {{if group.locked 'dma-card--locked'}}">
          <div class="dma-card__body">
            <h3 class="dma-card__heading"><span class="dma-card__heading-icon"><svg viewBox="0 -960 960 960"><path d={{group.iconPath}} /></svg></span>{{group.name}}</h3>
            <p class="dma-card__description">{{group.desc}}</p>

            <div class="dma-tile-grid">
              {{#each group.items as |item|}}
                <div class="dma-tile {{unless item.enabled 'dma-tile--disabled'}}">

                  <div class="dma-tile__header">
                    {{#if (hasIcon item.parsed.icon)}}
                      <div class="dma-tile__icon" style="background-color: {{item.parsed.color}};">
                        <svg
                          viewBox={{getIconViewBox item.parsed.icon}}
                          width="14"
                          height="14"
                          fill="white"
                        >
                          {{#each (getIconPaths item.parsed.icon) as |pathData|}}
                            <path
                              d={{pathData.d}}
                              fill={{if pathData.fill pathData.fill "white"}}
                              stroke={{if pathData.stroke pathData.stroke ""}}
                              stroke-width={{if pathData.strokeWidth pathData.strokeWidth ""}}
                            />
                          {{/each}}
                        </svg>
                      </div>
                    {{else}}
                      <div class="dma-tile__icon" style="background-color: {{item.parsed.color}};">
                        {{getInitial item.parsed.icon}}
                      </div>
                    {{/if}}

                    <span class="dma-tile__title">{{item.parsed.title}}</span>

                    {{#if (isItemToggleable item)}}
                      <label class="dma-toggle dma-toggle--sm {{if (isFeatureUnavailable item @controller.computedForumFeatures) 'dma-toggle--disabled'}}">
                        <input
                          type="checkbox"
                          checked={{item.enabled}}
                          disabled={{isFeatureUnavailable item @controller.computedForumFeatures}}
                          {{on "change" (fn @controller.toggleItem item)}}
                        />
                        <span class="dma-toggle__track"></span>
                      </label>
                    {{/if}}
                  </div>

                  <span class="dma-tile__desc">{{item.parsed.description}}</span>

                  {{#if item.parsed.comingSoon}}
                    <span class="dma-tile__badge dma-tile__badge--coming-soon">Coming Soon</span>
                  {{else if item.parsed.featureKey}}
                    <span class="dma-tile__badge {{featureBadgeClass item @controller.computedForumFeatures}}">{{featureBadgeText item @controller.computedForumFeatures}}</span>
                  {{/if}}
                </div>
              {{/each}}
            </div>
          </div>
          {{#if group.locked}}<DmaLicenseLock />{{/if}}
        </div>
      {{/each}}
      </:content>
    </DmaPageLayout>
  </template>
}
