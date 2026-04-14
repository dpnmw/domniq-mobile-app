import Component from "@glimmer/component";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import ICONS from "./domniq-icons";
import DmaPageLayout from "./dma-page-layout";

const CATEGORY_META = {
  Playground: {
    color: "#A358DF",
    cardClass: "dma-card--playground",
    desc: "Featured content and upcoming experiences shown at the top of the app drawer.",
  },
  Community: {
    color: "#4ECDC4",
    cardClass: "dma-card--community",
    desc: "Social features, leaderboards, and community information.",
  },
  Settings: {
    color: "#F5A623",
    cardClass: "dma-card--settings",
    desc: "User preferences for appearance, notifications, and device permissions.",
  },
  Support: {
    color: "#74b9ff",
    cardClass: "dma-card--support",
    desc: "Help resources, developer info, and contact options.",
  },
  "Admin Dashboard": {
    color: "#EF5350",
    cardClass: "dma-card--admin",
    desc: "Staff-only tools for site analytics, user management, and moderation.",
  },
};

const CATEGORY_ORDER = ["Playground", "Community", "Settings", "Support", "Admin Dashboard"];

function sortedCategories(groupedItems) {
  return CATEGORY_ORDER.filter((cat) => groupedItems[cat]).map((cat) => ({
    name: cat,
    items: groupedItems[cat],
    color: CATEGORY_META[cat]?.color || "#999",
    cardClass: CATEGORY_META[cat]?.cardClass || "",
    desc: CATEGORY_META[cat]?.desc || "",
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
    <DmaPageLayout @title="App Drawer" @subtitle="Control which menu items appear in the app's sidebar. Toggle visibility, reorder, and manage feature gates.">
      <:icon>
        <svg viewBox="0 -960 960 960" width="24" height="24" fill="white">
          <path d="M186.67-120q-27 0-46.84-19.83Q120-159.67 120-186.67v-586.66q0-27 19.83-46.84Q159.67-840 186.67-840h586.66q27 0 46.84 19.83Q840-800.33 840-773.33v586.66q0 27-19.83 46.84Q800.33-120 773.33-120H186.67Zm0-66.67h586.66v-586.66H186.67v586.66ZM480-280q17 0 28.5-11.5T520-320q0-17-11.5-28.5T480-360q-17 0-28.5 11.5T440-320q0 17 11.5 28.5T480-280Zm-160 0q17 0 28.5-11.5T360-320q0-17-11.5-28.5T320-360q-17 0-28.5 11.5T280-320q0 17 11.5 28.5T320-280Zm320 0q17 0 28.5-11.5T680-320q0-17-11.5-28.5T640-360q-17 0-28.5 11.5T600-320q0 17 11.5 28.5T640-280Z" />
        </svg>
      </:icon>

      {{#each (sortedCategories @controller.groupedItems) as |group|}}
        <div class="dma-card {{group.cardClass}}">
          <div class="dma-card__body">
            <h3 class="dma-card__heading">{{group.name}}</h3>
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

                    <label class="dma-toggle dma-toggle--sm">
                      <input
                        type="checkbox"
                        checked={{item.enabled}}
                        {{on "change" (fn @controller.toggleItem item)}}
                      />
                      <span class="dma-toggle__track"></span>
                    </label>
                  </div>

                  <span class="dma-tile__desc">{{item.parsed.description}}</span>

                  {{#if item.parsed.comingSoon}}
                    <span class="dma-tile__badge dma-tile__badge--coming-soon">Soon</span>
                  {{else if item.parsed.featureKey}}
                    <span class="dma-tile__badge dma-tile__badge--gated">{{item.parsed.featureKey}}</span>
                  {{else if item.parsed.requiresStaff}}
                    <span class="dma-tile__badge dma-tile__badge--staff">Staff</span>
                  {{/if}}
                </div>
              {{/each}}
            </div>
          </div>
        </div>
      {{/each}}
    </DmaPageLayout>
  </template>
}
