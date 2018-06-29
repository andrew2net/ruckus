module BuilderHelper
  # todo: after footer check if it's still
  def modal_classes(add_classes = nil)
    ['edit-link js-edit-modal', add_classes].compact.join(' ')
  end
end
