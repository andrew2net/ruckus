class ProfileDecorator < Draper::Decorator

  delegate_all

  def image_for_question_modal(account_is_editing)
    h.image_tag photo_url(:middle_thumb), alt: name unless photo.blank? && !account_is_editing
  end

  def candidate?
    is_a?(CandidateProfile)
  end

  def organization?
    is_a?(OrganizationProfile)
  end

  def labels
    @labels ||= LabelsDictionary.new(model)
  end

  def account_editing?
    context[:account_editing]
  end
end
