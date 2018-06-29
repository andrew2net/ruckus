require 'rails_helper'

describe BuilderHelper do
  describe 'modal_classes' do
    specify { expect(modal_classes).to eq 'edit-link js-edit-modal' }
    specify { expect(modal_classes('test class')).to eq 'edit-link js-edit-modal test class' }
  end
end
