import Component from "@glimmer/component";
import DPageSubheader from "discourse/components/d-page-subheader";
import { i18n } from "discourse-i18n";
import APP_VERSION from "./dma-version";
export default class DomniqWelcome extends Component {
  get currentYear() {
    return new Date().getFullYear();
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
          <p class="dma-welcome__feature-desc">Toggle feature flags like post participants, story layout, and video thumbnails.</p>
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
          <h3 class="dma-welcome__feature-title">Premium</h3>
          <p class="dma-welcome__feature-desc">Activate your licence for advanced configuration controls. Managed through DPN Media Works.</p>
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
