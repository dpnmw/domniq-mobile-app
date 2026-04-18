import Component from "@glimmer/component";

export default class DmaLicenseLock extends Component {
  <template>
    <div class="dma-license-lock">
      <div class="dma-license-lock__content">
        <span class="dma-license-lock__icon">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0110 0v4"/></svg>
        </span>
        <span class="dma-license-lock__text">Requires licence to unlock</span>
        <a href="/admin/plugins/domniq-mobile-app/dma-premium" class="dma-license-lock__btn">Get a Licence</a>
      </div>
    </div>
  </template>
}
