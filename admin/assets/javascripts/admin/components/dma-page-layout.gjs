import Component from "@glimmer/component";
import DPageSubheader from "discourse/components/d-page-subheader";
import { i18n } from "discourse-i18n";

const APP_VERSION = "1.0.0";
export default class DmaPageLayout extends Component {
  get currentYear() {
    return new Date().getFullYear();
  }

  <template>
    <section class="dma-page">

      {{! ── Hero ── }}
      <div class="dma-page__hero">
        <div class="dma-page__hero-glow"></div>
        <div class="dma-page__hero-content">
          <div class="dma-page__icon">
            {{yield to="icon"}}
          </div>
          <DPageSubheader
            @titleLabel={{i18n @titleLabel}}
            @descriptionLabel={{i18n @descriptionLabel}}
          />
          <div class="dma-page__version">
            <span class="dma-page__version-badge">v{{APP_VERSION}}</span>
          </div>
        </div>
      </div>

      {{! ── Content ── }}
      <div class="dma-page__content">
        {{yield to="content"}}
      </div>

      {{! ── Footer ── }}
      <div class="dma-page__footer">
        <div class="dma-page__footer-divider"></div>
        <p class="dma-page__footer-text">
          Powered by <a href="https://domniq.app" target="_blank" rel="noopener noreferrer">Domniq</a> — A Native Discourse Mobile App
        </p>
        <p class="dma-page__footer-copy">
          &copy; {{this.currentYear}} <a href="https://dpnmediaworks.com" target="_blank" rel="noopener noreferrer">DPN MEDIA WORKS</a>. All rights reserved.
        </p>
      </div>

    </section>
  </template>
}
