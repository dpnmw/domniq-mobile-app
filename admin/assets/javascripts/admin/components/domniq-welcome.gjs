import Component from "@glimmer/component";
import DPageSubheader from "discourse/components/d-page-subheader";
import { i18n } from "discourse-i18n";

const APP_VERSION = "1.0.0";
const API_BASE = "https://api.dpnmediaworks.com";

export default class DomniqWelcome extends Component {
  get currentYear() {
    return new Date().getFullYear();
  }

  get buyUrl() {
    return `${API_BASE}/pay/discourse/domniq-mobile-app`;
  }

  <template>
    <section class="dma-welcome">

      {{! ── Hero ── }}
      <div class="dma-welcome__hero">
        <div class="dma-welcome__hero-glow"></div>
        <div class="dma-welcome__hero-content">
          <div class="dma-welcome__logo">
            <svg viewBox="0 -960 960 960" width="32" height="32" fill="white">
              <path d="M186.67-120q-27 0-46.84-19.83Q120-159.67 120-186.67v-586.66q0-27 19.83-46.84Q159.67-840 186.67-840h586.66q27 0 46.84 19.83Q840-800.33 840-773.33v586.66q0 27-19.83 46.84Q800.33-120 773.33-120H186.67Zm0-66.67h586.66v-586.66H186.67v586.66Zm0-586.66v586.66-586.66ZM480-280q17 0 28.5-11.5T520-320q0-17-11.5-28.5T480-360q-17 0-28.5 11.5T440-320q0 17 11.5 28.5T480-280Zm-160 0q17 0 28.5-11.5T360-320q0-17-11.5-28.5T320-360q-17 0-28.5 11.5T280-320q0 17 11.5 28.5T320-280Zm320 0q17 0 28.5-11.5T680-320q0-17-11.5-28.5T640-360q-17 0-28.5 11.5T600-320q0 17 11.5 28.5T640-280Z" />
            </svg>
          </div>
          <DPageSubheader
            @titleLabel={{i18n "domniq_app.admin.title"}}
            @descriptionLabel={{i18n "domniq_app.admin.overview.description"}}
          />
          <div class="dma-welcome__version">
            <span class="dma-welcome__version-badge">v{{APP_VERSION}}</span>
          </div>
        </div>
      </div>

      {{! ── What is this ── }}
      <div class="dma-welcome__intro">
        <p class="dma-welcome__intro-text">
          This plugin connects your Discourse forum to the DOMNiQ mobile app — a fully native
          iOS and Android experience. Manage push notifications, app drawer layout, feature flags,
          branding, onboarding content, and translations directly from this admin panel.
        </p>
      </div>

      {{! ── Feature Grid ── }}
      <div class="dma-welcome__grid">

        <div class="dma-welcome__feature">
          <div class="dma-welcome__feature-icon dma-welcome__feature-icon--blue">
            <svg viewBox="0 -960 960 960" width="22" height="22" fill="white">
              <path d="M186.67-120q-27 0-46.84-19.83Q120-159.67 120-186.67v-586.66q0-27 19.83-46.84Q159.67-840 186.67-840h586.66q27 0 46.84 19.83Q840-800.33 840-773.33v586.66q0 27-19.83 46.84Q800.33-120 773.33-120H186.67Zm0-66.67h586.66v-586.66H186.67v586.66ZM480-280q17 0 28.5-11.5T520-320q0-17-11.5-28.5T480-360q-17 0-28.5 11.5T440-320q0 17 11.5 28.5T480-280Zm-160 0q17 0 28.5-11.5T360-320q0-17-11.5-28.5T320-360q-17 0-28.5 11.5T280-320q0 17 11.5 28.5T320-280Zm320 0q17 0 28.5-11.5T680-320q0-17-11.5-28.5T640-360q-17 0-28.5 11.5T600-320q0 17 11.5 28.5T640-280Z" />
            </svg>
          </div>
          <h3 class="dma-welcome__feature-title">App Drawer</h3>
          <p class="dma-welcome__feature-desc">Control which menu items appear in the app's sidebar. Toggle visibility, reorder, and manage feature gates.</p>
        </div>

        <div class="dma-welcome__feature">
          <div class="dma-welcome__feature-icon dma-welcome__feature-icon--teal">
            <svg viewBox="0 -960 960 960" width="22" height="22" fill="white">
              <path d="M479.99-689.33q15.01 0 25.18-10.16 10.16-10.15 10.16-25.17 0-15.01-10.15-25.17Q495.02-760 480.01-760q-15.01 0-25.18 10.15-10.16 10.16-10.16 25.17 0 15.01 10.15 25.18 10.16 10.17 25.17 10.17Zm-33.32 324.66h66.66V-612h-66.66v247.33ZM80-80v-733.33q0-27 19.83-46.84Q119.67-880 146.67-880h666.66q27 0 46.84 19.83Q880-840.33 880-813.33v506.66q0 27-19.83 46.84Q840.33-240 813.33-240H240L80-80Z" />
            </svg>
          </div>
          <h3 class="dma-welcome__feature-title">Configuration</h3>
          <p class="dma-welcome__feature-desc">Set app branding, color palette, onboarding slides, about screen behavior, and legal links.</p>
        </div>

        <div class="dma-welcome__feature">
          <div class="dma-welcome__feature-icon dma-welcome__feature-icon--orange">
            <svg viewBox="0 -960 960 960" width="22" height="22" fill="white">
              <path d="M446.67-120v-280L249.33-202.33l-47-47L400-446.67H120v-66.66h280.67l-198.34-198 47-47 197.34 197.66V-840h66.66v280l198-198.33 47 47-198.33 198h280v66.66H560.67l197.66 197.34-47 47-198-198.34V-120h-66.66Z" />
            </svg>
          </div>
          <h3 class="dma-welcome__feature-title">Features</h3>
          <p class="dma-welcome__feature-desc">Toggle feature flags like post participants, story layout, reply mode, and video thumbnails.</p>
        </div>

        <div class="dma-welcome__feature">
          <div class="dma-welcome__feature-icon dma-welcome__feature-icon--pink">
            <svg viewBox="0 -960 960 960" width="22" height="22" fill="white">
              <path d="M518.33-501.33ZM480-80q-33 0-56.5-23.5T400-160h160q0 33-23.5 56.5T480-80ZM160-200v-66.67h80v-296q0-83.66 49.67-149.5Q339.33-778 420-796v-24q0-25 17.5-42.5T480-880q25 0 42.5 17.5T540-820v24q31 7 57.5 21.83 26.5 14.84 48.17 35.5l-48.34 49q-23-21-53.33-33.66Q513.67-736 480-736q-72 0-122.67 50.67-50.66 50.66-50.66 122.66v296H800V-200H160Z" />
            </svg>
          </div>
          <h3 class="dma-welcome__feature-title">Notifications</h3>
          <p class="dma-welcome__feature-desc">Push notifications via Expo. View registered devices, send test notifications, and manage delivery.</p>
        </div>

        <div class="dma-welcome__feature">
          <div class="dma-welcome__feature-icon dma-welcome__feature-icon--purple">
            <svg viewBox="0 -960 960 960" width="22" height="22" fill="white">
              <path d="M240-289.33 49.33-480 240-670.67 286.67-624l-143 144 143 144L240-289.33Zm174 132.66-64-20 196.67-626.66L610-784 414-156.67Zm306-132.66L673.33-336l143-144-143-144L720-670.67 910.67-480 720-289.33Z" />
            </svg>
          </div>
          <h3 class="dma-welcome__feature-title">Language</h3>
          <p class="dma-welcome__feature-desc">Export English defaults as PO files, import translations, and let users switch languages in the app.</p>
        </div>

        <div class="dma-welcome__feature">
          <div class="dma-welcome__feature-icon dma-welcome__feature-icon--gold">
            <svg viewBox="0 -960 960 960" width="22" height="22" fill="white">
              <path d="M480-80.67q-139.67-35-229.83-161.5Q160-368.67 160-520.67v-240l320-120 320 120v240q0 152-90.17 278.5Q619.67-115.67 480-80.67Zm0-69.33q111.33-36.33 182.33-139.67 71-103.33 71-231v-193.66L480-809.67l-253.33 95.34v193.66q0 127.67 71 231Q368.67-186.33 480-150Z" />
            </svg>
          </div>
          <h3 class="dma-welcome__feature-title">Licensing</h3>
          <p class="dma-welcome__feature-desc">Activate your license for advanced configuration controls. Managed through DPN Media Works.</p>
        </div>

      </div>

      {{! ── White Label Pricing ── }}
      <div class="dma-welcome__pricing">
        <div class="dma-welcome__pricing-glow"></div>
        <div class="dma-welcome__pricing-content">
          <div class="dma-welcome__pricing-header">
            <span class="dma-welcome__pricing-badge">Early Adopter Pricing</span>
            <h2 class="dma-welcome__pricing-title">Your Brand. Your App.</h2>
            <p class="dma-welcome__pricing-subtitle">Get a fully white-labeled native mobile app for your Discourse community — published under your name on both the App Store and Google Play.</p>
          </div>

          <div class="dma-welcome__pricing-cards">
            <div class="dma-welcome__pricing-card">
              <div class="dma-welcome__pricing-card-icon dma-welcome__pricing-card-icon--ios">
                <svg viewBox="0 0 24 24" width="28" height="28" fill="white"><path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.8-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z"/></svg>
              </div>
              <span class="dma-welcome__pricing-card-label">iOS App</span>
              <span class="dma-welcome__pricing-card-detail">App Store</span>
            </div>
            <div class="dma-welcome__pricing-card-plus">+</div>
            <div class="dma-welcome__pricing-card">
              <div class="dma-welcome__pricing-card-icon dma-welcome__pricing-card-icon--android">
                <svg viewBox="0 0 24 24" width="28" height="28" fill="white"><path d="M17.6 11.48l1.74-3c.17-.3.07-.68-.22-.85-.3-.17-.68-.07-.85.22l-1.76 3.06c-1.33-.6-2.81-.95-4.41-.95s-3.09.35-4.42.95L5.87 7.85c-.17-.29-.55-.39-.85-.22-.29.17-.39.55-.22.85l1.74 3C3.69 13.21 1.72 16 1.5 19.5h21c-.22-3.5-2.19-6.29-4.9-8.02zM7 17.25c-.55 0-1-.45-1-1s.45-1 1-1 1 .45 1 1-.45 1-1 1zm10 0c-.55 0-1-.45-1-1s.45-1 1-1 1 .45 1 1-.45 1-1 1z"/></svg>
              </div>
              <span class="dma-welcome__pricing-card-label">Android App</span>
              <span class="dma-welcome__pricing-card-detail">Google Play</span>
            </div>
          </div>

          <div class="dma-welcome__pricing-price">
            <span class="dma-welcome__pricing-original">$299</span>
            <div class="dma-welcome__pricing-sale">
              <span class="dma-welcome__pricing-currency">$</span>
              <span class="dma-welcome__pricing-amount">199</span>
              <span class="dma-welcome__pricing-cents">.99</span>
              <span class="dma-welcome__pricing-period">/year</span>
            </div>
            <span class="dma-welcome__pricing-save">Save $100</span>
          </div>

          <ul class="dma-welcome__pricing-features">
            <li>Custom app name, icon &amp; branding</li>
            <li>Published on App Store &amp; Google Play under your name</li>
            <li>No DOMNiQ branding anywhere in the app</li>
            <li>Full admin panel control (drawer, config, features)</li>
            <li>Push notifications for your community</li>
            <li>Multi-language support via PO translations</li>
            <li>Ongoing updates &amp; Discourse compatibility</li>
            <li>Priority support from DPN Media Works</li>
          </ul>

          <a href="{{this.buyUrl}}" target="_blank" rel="noopener noreferrer" class="dma-welcome__pricing-cta">
            Get Your White-Label App
          </a>
          <p class="dma-welcome__pricing-note">Annual subscription. Billed yearly via PayPal. Cancel anytime.</p>
        </div>
      </div>

      {{! ── Footer ── }}
      <div class="dma-welcome__footer">
        <div class="dma-welcome__footer-divider"></div>
        <p class="dma-welcome__footer-text">
          Powered by <a href="https://domniq.app" target="_blank" rel="noopener noreferrer">Domniq</a> — A Native Discourse Mobile App
        </p>
        <p class="dma-welcome__footer-copy">
          &copy; {{this.currentYear}} <a href="https://dpnmediaworks.com" target="_blank" rel="noopener noreferrer">DPN MEDIA WORKS</a>. All rights reserved.
        </p>
      </div>

    </section>
  </template>
}
