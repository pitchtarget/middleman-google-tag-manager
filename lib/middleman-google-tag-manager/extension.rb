require 'middleman-core'

class GoogleTagManager < ::Middleman::Extension
  option :container_id, ENV['GTM_CONTAINER_ID'], 'Google Tag Manager container ID'
  option :gtm_preview, ENV['GTM_PREVIEW'], 'Google Tag Preview'
  option :gtm_auth, ENV['GTM_AUTH'], 'Google Tag Auth'

  option :amp_container_id, ENV['AMP_GTM_CONTAINER_ID'], 'AMP Google Tag Manager container ID'
  option :amp_gtm_preview, ENV['AMP_GTM_PREVIEW'], 'AMP Google Tag Preview'
  option :amp_gtm_auth, ENV['AMP_GTM_AUTH'], 'AMP Google Tag Auth'

  option :development, true, 'Render tag in development environment'

  def after_configuration
    unless options.container_id
      $stderr.puts 'Google Tag Manager: Please specify a container ID'
      raise ArgumentError, 'No container ID given' if display?
    end
  end

  helpers do
    def google_tag_manager_body
      options = extensions[:google_tag_manager].options
      return unless !legacy_development? || options.development

      <<-END
<!-- Google Tag Manager (noscript) -->
<noscript><iframe src="https://www.googletagmanager.com/ns.html?id=#{options.container_id}&gtm_auth=#{options.gtm_auth}&gtm_preview=#{options.gtm_preview}&gtm_cookies_win=x"
height="0" width="0" style="display:none;visibility:hidden"></iframe></noscript>
<!-- End Google Tag Manager (noscript) -->
      END
    end

    def google_tag_manager_head
      options = extensions[:google_tag_manager].options
      return unless !legacy_development? || options.development

      <<-END
<!-- Google Tag Manager -->
<script>(function(w,d,s,l,i){w[l]=w[l]||[];w[l].push({'gtm.start':
new Date().getTime(),event:'gtm.js'});var f=d.getElementsByTagName(s)[0],
j=d.createElement(s),dl=l!='dataLayer'?'&l='+l:'';j.async=true;j.src=
'https://www.googletagmanager.com/gtm.js?id='+i+dl+ '&gtm_auth=#{options.gtm_auth}&gtm_preview=#{options.gtm_preview}&gtm_cookies_win=x';f.parentNode.insertBefore(j,f);
})(window,document,'script','dataLayer','#{options.container_id}');</script>
<!-- End Google Tag Manager -->
      END
    end

    def google_tag_manager_amp_body(content)
      options = extensions[:google_tag_manager].options
      return unless !legacy_development? || options.development

      <<-END
<!-- Google Tag Manager -->
<amp-analytics config="https://www.googletagmanager.com/amp.json?id=#{options.amp_container_id}&gtm_auth=#{options.amp_gtm_auth}&gtm_preview=#{options.amp_gtm_preview}&gtm_cookies_win=x&gtm.url=SOURCE_URL" data-credentials="include">
#{content}
</amp-analytics>
      END
    end

    def google_tag_manager_amp_head
      options = extensions[:google_tag_manager].options
      return unless !legacy_development? || options.development

      <<-END
<!-- AMP Analytics --><script async custom-element="amp-analytics" src="https://cdn.ampproject.org/v0/amp-analytics-0.1.js"></script>
      END
    end

    # Support for Middleman >= 3.4
    def legacy_development?
      # Middleman 3.4
      is_development = try(:development?)
      unless is_development.nil?
        return is_development
      end

      # Middleman 4.x
      app.development?
    end
  end

  private

  def display?
    app.build? || app.development? && options.development
  end

end
