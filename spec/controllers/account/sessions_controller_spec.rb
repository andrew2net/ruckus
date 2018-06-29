require 'rails_helper'

describe Account::SessionsController do
  specify 'GET new' do
    get :new
    expect(response).to render_template 'new'
  end

  describe 'POST create' do
    let(:account) { create(:account) }

    specify 'success' do
      xhr :post, :create, account: { email: account.email, password: account.password }

      expect(flash[:notice]).to eq 'Signed in successfully.'
      expect(response).to render_template 'create'
    end

    specify 'failure' do
      xhr :post, :create, account: { email: nil }

      expect(flash[:alert]).to eq 'Invalid email or password'
      expect(response).to render_template 'create'
    end
  end
end
