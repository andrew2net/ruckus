class CheckBoxAddonInput < SimpleForm::Inputs::BooleanInput
  def input
    template.content_tag(:span, class: html_class) do
      super
    end
  end

  def label_input(wrapper_options)
    input
  end

  private

  def checked?
    object.public_send("#{attribute_name}?")
  end

  def html_class
    "check-box #{checked? ? 'active' : ''}"
  end
end
