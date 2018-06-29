require 'rails_helper'

describe Profile::EventsController do
  let!(:profile) { create :candidate_profile }
  let(:account)  { create :account, profile: profile }
  let!(:event)   { create :event, profile: profile }
  let!(:valid_event_attributes) do
    {
      title: 'The Title',
      start_time_time: '2:30PM',
      start_time_date: '02/02/2015',
      end_time_time: '2:30PM',
      end_time_date: '02/02/2025',
      city: 'Denver',
      state: 'CO'
    }
  end

  before { sign_in account }

  describe 'GET #new' do
    check_authorizing { get :new }

    specify 'opening the modal' do
      get :new
      expect(response).to render_template :new
    end

    specify 'loading form into opened modal' do
      xhr :get, :new
      expect(response).to render_template :new
    end
  end

  describe 'GET #index' do
    check_authorizing { get :index }

    specify 'opening the modal' do
      get :index
      expect(response).to render_template :index
    end

    specify 'loading list into opened modal' do
      xhr :get, :index
      expect(response).to render_template :index
    end

    describe 'set_date' do
      specify 'not present' do
        xhr :get, :index
        expect(assigns(:date)).to eq Date.today
      end

      specify 'present' do
        xhr :get, :index, month: '2015-05'
        expect(assigns(:date)).to eq Date.parse('May 2015')
      end
    end
  end

  describe 'GET #edit' do
    check_authorizing { get :edit, id: event.id }

    specify 'opening the modal' do
      get :edit, id: event.id
      expect(response).to render_template 'edit'
    end
  end

  describe 'PATCH #update' do
    check_authorizing do
      patch :update, id:    event.id,
                     event: {
                       title:         'New Title',
                       link_text:     'Link Text',
                       link_url:      'http://google.com',
                       end_time_date: '12/12/2015',
                       end_time_time: '9AM',
                       time_zone:     'EDT'
                     },
                     format: :js
    end

    xspecify 'update with valid params' do
      expect_any_instance_of(MixpanelTracker).to receive(:track_event).with(:event_update)

      patch :update, id:    event.id,
                     event: {
                       title:         'New Title',
                       link_text:     'Link Text',
                       link_url:      'http://google.com',
                       end_time_date: '12/12/2016',
                       end_time_time: '9AM',
                       time_zone:     'EDT'
                     },
                     format: :js

      expect(response).to render_template 'show'

      event.reload.tap do |event|
        expect(event.title).to eq 'New Title'
        expect(I18n.l(event.end_time, format: :default_hours)).to eq ' 9:00AM'
        expect(event.link_text).to eq 'Link Text'
        expect(event.link_url).to eq 'http://google.com'
      end
    end

    specify 'loading form into opened modal' do
      xhr :get, :edit, id: event.id
      expect(response).to render_template 'edit'
    end
  end

  describe 'POST #create' do
    check_authorizing { post :create, event: valid_event_attributes, format: :js }

    specify 'success' do
      expect_any_instance_of(MixpanelTracker).to receive(:track_event).with(:add_new_event)
      expect { post :create, event: valid_event_attributes, format: :js }
        .to change(profile.events, :count).by 1

      expect(response).to render_template :show
    end

    specify 'failure' do
      expect { post :create, event: valid_event_attributes.merge(title: ''), format: :js }
        .to change(profile.events, :count).by 0

      expect(response).to render_template :create
    end
  end

  describe 'PATCH #update' do
    specify 'success' do
      expect do
        patch :update, id: event.id,
                       event: valid_event_attributes.merge(title: 'New title'),
                       format: :js
      end.to change(profile.events, :count).by 0

      expect(response).to render_template :show
      expect(event.reload.title).to eq 'New title'
    end

    specify 'failure' do
      expect do
        patch :update, id: event.id, event: valid_event_attributes.merge(title: ''), format: :js
      end.to change(profile.events, :count).by 0

      expect(response).to render_template :update
    end
  end

  specify 'DELETE #destroy' do
    expect do
      delete :destroy, id: event.id, format: :js
    end.to change(profile.events, :count).by(-1)

    expect(response).to render_template 'destroy'
  end
end
