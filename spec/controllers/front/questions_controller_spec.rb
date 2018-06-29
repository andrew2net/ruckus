require 'rails_helper'

describe Front::QuestionsController do
  let!(:account)  { create :account, email: 'testaccount@gmail.com' }
  let!(:profile)  { create :candidate_profile, account: account }

  specify 'GET #new' do
    get :new, profile_id: profile.id
    expect(response).to render_template 'new'
    expect(response).not_to render_template 'layouts/application'
  end

  describe 'POST #create' do
    let(:question_attrs) { attributes_for(:question, user_attributes: attributes_for(:user, email: 'user@test.com', first_name: 'John', last_name: 'Smith')) }

    describe 'success' do
      after { expect(response).to render_template 'create' }

      it 'should send a notification to question asker' do
        expect_any_instance_of(MixpanelTracker).to receive(:track_event).with(:visitor_question, { questioner_name: 'John Smith', questioner_email: 'user@test.com', questioner_date: Date.today })

        xhr :post, :create, profile_id: profile.id, question: question_attrs

        mails = ActionMailer::Base.deliveries

        mails.select{ |mail| mail.subject == 'Question Successfully Submitted' }.first.tap do |mail|
          expect(mail).to be_present
          expect(mail.to.first).to eq 'user@test.com'
        end

        mails.select{ |mail| mail.subject == 'Question' }.first.tap do |mail|
          expect(mail).to be_present
          expect(mail.to.first).to eq 'testaccount@gmail.com'
        end
      end

      it 'should create question' do
        expect {
          allow_any_instance_of(AccountMailer).to receive(:question_message)
          xhr :post, :create, profile_id: profile.id, question: question_attrs
        }.to change(Question, :count).by(1)
      end

      it 'should create user' do
        expect {
          xhr :post, :create, profile_id: profile.id, question: question_attrs
        }.to change(User, :count).by(1)
      end

      it 'should not create user' do
        user = create(:user)
        user_attributes = attributes_for(:user, email: user.email)
        question_attrs[:user_attributes] = user_attributes

        expect {
          xhr :post, :create, profile_id: profile.id, question: question_attrs
        }.to change(User, :count).by(0)

        expect(assigns(:question).user.email).to eq user.email
        expect(assigns(:question).user.first_name).to eq user_attributes[:first_name]
        expect(assigns(:question).user.last_name).to eq user_attributes[:last_name]
      end
    end

    specify 'error' do
      question_attrs[:text] = nil

      expect {
        xhr :post, :create, profile_id: profile.id, question: question_attrs
      }.to change(Question, :count).by(0)

      expect(response).to render_template 'create'
    end
  end
end
