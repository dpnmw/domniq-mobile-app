import Component from "@glimmer/component";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import DPageSubheader from "discourse/components/d-page-subheader";
import { i18n } from "discourse-i18n";
import ICONS from "./domniq-icons";

const CATEGORY_COLORS = {
  Playground: "#A358DF",
  Community: "#4ECDC4",
  Settings: "#F5A623",
  Support: "#74b9ff",
};

const CATEGORY_CARD_CLASS = {
  Playground: "dma-card--playground",
  Community: "dma-card--community",
  Settings: "dma-card--settings",
  Support: "dma-card--support",
};

const CATEGORY_ORDER = ["Playground", "Community", "Settings", "Support"];

function sortedCategories(groupedItems) {
  return CATEGORY_ORDER.filter((cat) => groupedItems[cat]).map((cat) => ({
    name: cat,
    items: groupedItems[cat],
    color: CATEGORY_COLORS[cat] || "#999",
    cardClass: CATEGORY_CARD_CLASS[cat] || "",
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

export default class DomniqDrawerEditor extends Component {
  <template>
    <section class="domniq-admin">
      <DPageSubheader
        @titleLabel={{i18n "domniq_app.admin.drawer.title"}}
        @descriptionLabel={{i18n "domniq_app.admin.drawer.description"}}
      />

      {{#each (sortedCategories @controller.groupedItems) as |group|}}
        <div class="dma-card {{group.cardClass}}">
          <div class="dma-card__body">
            <h3 class="dma-card__heading">{{group.name}}</h3>
            <p class="dma-card__description">{{group.items.length}} items</p>

            <div class="dma-drawer-grid">
              {{#each group.items as |item|}}
                <div class="dma-drawer-item {{unless item.enabled 'dma-drawer-item--disabled'}}">

                  {{#if (hasIcon item.parsed.icon)}}
                    <div class="dma-drawer-item__icon" style="background-color: {{item.parsed.color}};">
                      <svg
                        viewBox={{getIconViewBox item.parsed.icon}}
                        width="18"
                        height="18"
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
                    <div class="dma-drawer-item__icon" style="background-color: {{item.parsed.color}};">
                      {{getInitial item.parsed.icon}}
                    </div>
                  {{/if}}

                  <div class="dma-drawer-item__info">
                    <div class="dma-drawer-item__title">
                      {{item.parsed.title}}
                    </div>
                    <div class="dma-drawer-item__desc">
                      {{item.parsed.description}}
                    </div>
                  </div>

                  <div class="dma-drawer-item__meta">
                    {{#if item.parsed.comingSoon}}
                      <span class="dma-drawer-item__badge dma-drawer-item__badge--coming-soon">Coming Soon</span>
                    {{/if}}
                    {{#if item.parsed.featureKey}}
                      <span class="dma-drawer-item__badge dma-drawer-item__badge--gated">{{item.parsed.featureKey}}</span>
                    {{/if}}

                    <label class="dma-toggle">
                      <input
                        type="checkbox"
                        checked={{item.enabled}}
                        {{on "change" (fn @controller.toggleItem item)}}
                      />
                      <span class="dma-toggle__track"></span>
                    </label>
                  </div>
                </div>
              {{/each}}
            </div>
          </div>
        </div>
      {{/each}}
    </section>
  </template>
}

function getIconViewBox(iconName) {
  const icon = getIconData(iconName);
  return icon ? icon.viewBox : "0 0 24 24";
}

function getIconPaths(iconName) {
  const icon = getIconData(iconName);
  return icon ? icon.paths : [];
}
