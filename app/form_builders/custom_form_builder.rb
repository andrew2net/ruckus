class CustomFormBuilder < SimpleForm::FormBuilder
  def submit(*args)
    options = args.extract_options!

    classes = ['button']
    classes << options[:class]
    classes = classes.compact.join(' ')

    data = options[:data] || {}
    data.merge!(disable_with: 'Please wait...')

    args << options.merge!(data: data, class: classes)

    super
  end
end
