require 'rails_helper'

describe Front::PagesController do
  describe 'GET faq' do
    let!(:page) { create :page, name: 'faq', data: 'faq data'}

    specify do
      get :faq

      expect(response).to render_template :faq
      expect(assigns(:content)).to eq 'faq data'
    end
  end

  describe 'GET contact' do
    let!(:page) { create :page, name: 'contact', data: 'contact data'}

    specify do
      get :contact

      expect(response).to render_template :contact
      expect(assigns(:content)).to eq 'contact data'
    end
  end

  describe 'GET terms' do
    let!(:page) { create :page, name: 'terms', data: 'terms data'}

    specify do
      get :terms

      expect(response).to render_template :terms
      expect(assigns(:content)).to eq 'terms data'
    end
  end

  describe 'GET how_to_update_domain' do
    let!(:page) { create :page, name: 'how-to-update-domain', data: 'how-to-update-domain data'}

    specify do
      get :how_to_update_domain

      expect(response).to render_template :how_to_update_domain
      expect(assigns(:content)).to eq 'how-to-update-domain data'
    end
  end
end
