module NavigationHelper
  def custom_form_for(object, *args, &block)
    options = args.extract_options!
    options.merge!(builder: CustomFormBuilder, data: { remote: true })

    simple_form_for(object, *(args << options), &block)
  end

  def destroy_button(object)
    link_to resource_path(object), method: :delete,
                                   class: 'trash',
                                   rel:   'nofollow',
                                   remote: true,
                                   data: { confirm: 'Are you sure you want to delete this?' },
                                   tabindex: '-1' do
      content_tag :i, nil, class: 'icon-trash'
    end
  end

  def donations_url(profile)
    protocol = Rails.env.production? || Rails.env.staging? ? 'https' : 'http'
    front_profile_donations_url(profile, host: Figaro.env.domain, protocol: protocol)
  end
end
