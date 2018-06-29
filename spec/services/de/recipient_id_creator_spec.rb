require 'rails_helper'

describe De::RecipientIdCreator do
  let!(:params) { attributes_for :de_account }
  let!(:new_recipient_id)  { De::RecipientIdCreator.new(params) }

  describe '#initialize' do
    it 'should set object varialbes correctly' do
      expect(new_recipient_id.submitted_attrubutes).to eq params
      new_recipient_id.formatted_data.tap do |data|
        expect(data[:name]).to eq params[:account_full_name]
        expect(data[:remote_recipient_id]).to eq params[:uuid]
        expect(data[:registered_id]).to eq params[:account_committee_id]
        expect(data[:recipient_type]).to eq params[:account_recipient_kind]
        expect(data[:contact][:first_name]).to eq params[:contact_first_name]
        expect(data[:contact][:last_name]).to eq params[:contact_last_name]
        expect(data[:contact][:phone]).to eq params[:contact_phone]
        expect(data[:contact][:address1]).to eq params[:contact_address]
        expect(data[:contact][:state]).to eq params[:contact_state]
        expect(data[:contact][:zip]).to eq params[:contact_zip]
        expect(data[:contact][:bank_name]).to eq params[:bank_account_name]
        expect(data[:contact][:bank_routing_number]).to eq params[:bank_routing_number]
        expect(data[:contact][:bank_account_number]).to eq params[:bank_account_number]
        expect(data[:user][:login]).to eq params[:email]
        expect(data[:user][:initial_password]).to eq params[:password]
        expect(data[:user][:email]).to eq params[:email]
        expect(data[:recipient_tags][:party]).to eq params[:account_party]
        expect(data[:recipient_tags][:state]).to eq params[:account_state]
        expect(data[:recipient_tags][:locality]).to eq params[:account_district_or_locality]
      end
    end
  end

  describe '#process' do
    it 'should trigger data submission' do
      expect(DEApi).to receive(:create_recipient).with(new_recipient_id.formatted_data)
      new_recipient_id.process
    end
  end
end
