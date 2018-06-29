class BaseCell < Cell::ViewModel
  load('action_view/helpers/form_helper.rb')
  include ActionView::Helpers::AssetTagHelper
  include SimpleForm::ActionViewExtensions::FormHelper
  include ActionView::Helpers::FormHelper
  include NavigationHelper

  def render_general_info_pencil
    render partial: 'general_info_pencil' if show_navigation?
  end

  def render_tagline_or_placeholder
    show_tagline_placeholder? ? tagline_placeholder : profile.tagline
  end

  def labels
    @labels ||= LabelsDictionary.new(profile)
  end

  def show_navigation?
    profile.account_editing?
  end

  private
  def show_tagline_placeholder?
    profile.tagline.blank? && show_navigation?
  end

  def tagline_placeholder
    content_tag :span, 'Tagline', class: 'text-placeholder'
  end
end
