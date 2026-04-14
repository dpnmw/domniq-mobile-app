# frozen_string_literal: true

# Ensures video posts from the mobile app get a JPEG thumbnail as the topic image
# and injects the poster into the cooked HTML for web display.
#
# Videos uploaded via the Discourse web composer (no "poster:" in raw) are
# not affected — they follow Discourse's default behavior.

::CookedPostProcessor.class_eval do
  alias_method :original_update_post_image, :update_post_image

  def update_post_image
    original_update_post_image

    poster_match = @post.raw&.match(/poster:(\S+?)(?:\s|\|)/)
    return unless poster_match

    poster_url = poster_match[1]
    return if poster_url.blank?

    upload = find_poster_upload(poster_url)
    return unless upload

    if @post.is_first_post?
      should_set = false

      if @post.topic.image_upload_id.blank?
        should_set = true
      else
        existing = Upload.find_by(id: @post.topic.image_upload_id)
        should_set = existing.nil? || existing.url.match?(/\.(mp4|mov|webm|avi)(\?.*)?$/i)
      end

      if should_set
        @post.topic.update_column(:image_upload_id, upload.id)

        extra_sizes =
          ThemeModifierHelper.new(
            theme_ids: Theme.user_selectable.pluck(:id),
          ).topic_thumbnail_sizes
        @post.topic.generate_thumbnails!(extra_sizes: extra_sizes)
      end
    end

    inject_poster_into_cooked(poster_url, upload)
  end

  private

  def find_poster_upload(poster_url)
    clean_url = poster_url.sub(%r{\Ahttps?://[^/]+}, "")
    upload = Upload.find_by("url LIKE ?", "%#{clean_url}")

    if upload.nil?
      sha1_match = clean_url.match(%r{/([a-f0-9]{40})\.\w+$})
      upload = Upload.find_by(sha1: sha1_match[1]) if sha1_match
    end

    return nil if upload&.url&.match?(/\.(mp4|mov|webm|avi)(\?.*)?$/i)

    upload
  end

  def inject_poster_into_cooked(poster_url, upload)
    doc = @doc || Nokogiri::HTML5.fragment(@post.cooked)

    doc.css(".video-placeholder-container").each do |container|
      next if container["data-thumbnail-src"].present?

      full_poster_url = UrlHelper.cook_url(
        upload.url,
        secure: upload.secure?,
        local: true,
      )

      container["data-thumbnail-src"] = full_poster_url
      container["style"] = "cursor: pointer; background-image: url(\"#{full_poster_url}\");"
    end

    @post.update_column(:cooked, doc.to_html) if @post.cooked != doc.to_html
  end
end
