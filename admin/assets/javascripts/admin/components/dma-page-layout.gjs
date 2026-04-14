import Component from "@glimmer/component";

const APP_VERSION = "1.0.0";
const API_BASE = "https://api.dpnmediaworks.com";

export default class DmaPageLayout extends Component {
  get currentYear() {
    return new Date().getFullYear();
  }

  get buyUrl() {
    return `${API_BASE}/pay/discourse/domniq-mobile-app`;
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
          <h1 class="dma-page__title">{{@title}}</h1>
          <p class="dma-page__subtitle">{{@subtitle}}</p>
          <div class="dma-page__version">
            <span class="dma-page__version-badge">v{{APP_VERSION}}</span>
          </div>
        </div>
      </div>

      {{! ── Content ── }}
      <div class="dma-page__content">
        {{yield}}
      </div>

      {{! ── Licensing + Footer ── }}
      <div class="dma-page__licensing">
        <div class="dma-page__licensing-glow"></div>
        <div class="dma-page__licensing-content">
          <div class="dma-page__licensing-header">
            <span class="dma-page__licensing-badge">Limited Time Offer</span>
            <h2 class="dma-page__licensing-title">Your Brand. Your App.</h2>
            <p class="dma-page__licensing-subtitle">Get a fully white-labeled native mobile app for your Discourse community — published under your name on both the App Store and Google Play.</p>
          </div>

          <div class="dma-page__licensing-cards">
            <div class="dma-page__licensing-card">
              <div class="dma-page__licensing-card-icon dma-page__licensing-card-icon--ios">
                <svg viewBox="0 0 24 24" width="28" height="28" fill="white"><path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.8-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z"/></svg>
              </div>
              <span class="dma-page__licensing-card-label">iOS App</span>
              <span class="dma-page__licensing-card-detail">App Store</span>
            </div>
            <div class="dma-page__licensing-card-plus">+</div>
            <div class="dma-page__licensing-card">
              <div class="dma-page__licensing-card-icon dma-page__licensing-card-icon--android">
                <svg viewBox="0 0 24 24" width="28" height="28" fill="white"><path d="M17.6 11.48l1.74-3c.17-.3.07-.68-.22-.85-.3-.17-.68-.07-.85.22l-1.76 3.06c-1.33-.6-2.81-.95-4.41-.95s-3.09.35-4.42.95L5.87 7.85c-.17-.29-.55-.39-.85-.22-.29.17-.39.55-.22.85l1.74 3C3.69 13.21 1.72 16 1.5 19.5h21c-.22-3.5-2.19-6.29-4.9-8.02zM7 17.25c-.55 0-1-.45-1-1s.45-1 1-1 1 .45 1 1-.45 1-1 1zm10 0c-.55 0-1-.45-1-1s.45-1 1-1 1 .45 1 1-.45 1-1 1z"/></svg>
              </div>
              <span class="dma-page__licensing-card-label">Android App</span>
              <span class="dma-page__licensing-card-detail">Google Play</span>
            </div>
          </div>

          <div class="dma-page__licensing-price">
            <span class="dma-page__licensing-original">$199</span>
            <div class="dma-page__licensing-sale">
              <span class="dma-page__licensing-currency">$</span>
              <span class="dma-page__licensing-amount">149</span>
              <span class="dma-page__licensing-cents">.99</span>
              <span class="dma-page__licensing-period">/year</span>
            </div>
            <span class="dma-page__licensing-save">Save $49</span>
          </div>

          <a href="{{this.buyUrl}}" target="_blank" rel="noopener noreferrer" class="dma-page__licensing-cta">
            Get Your White-Label App
          </a>
          <p class="dma-page__licensing-note">Annual subscription. Billed yearly via PayPal. Cancel anytime.</p>
        </div>
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
