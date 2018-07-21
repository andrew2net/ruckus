#!/usr/bin/env ruby

require 'rubygems'
gem 'httparty', '>0.10.0'    # To install: sudo gem install httpparty
require 'httparty'
require 'pp'
#require 'ap'
require 'active_support/all'
require "yaml"
require "hashie" # gem install hashie

class DEApi
  include HTTParty

  @@auth = Hashie::Mash.new(DEMOCRACYENGINE_CREDENTIALS)

  digest_auth @@auth.username, @@auth.password
  base_uri "#{@@auth.uri}/subscribers/#{@@auth.account_number}"

  def self.get_account
    h = self.get(".json").parsed_response
    if h.is_a?(Hash)
      mash = Hashie::Mash.new(h)
      mash
    else
      raise "Could not get account hash\n#{h}"
      Hashie::Mash.new()
    end
  end

  # Get the account, then pull a uri out of the hash and go get that.
  def self.get_account_uri(uri)
    self.get(get_account[uri]).parsed_response
  end

  def self.create_recipient(data)
    post(get_account['recipient_process_uri'], body: { recipient: data }).parsed_response
  end

  def self.show_recipient(uuid)
    get(get_account['recipient_uri'].sub(':recipient_id', uuid)).parsed_response
  end

  def self.create_donation(data)
    post(get_account['donation_process_uri'], body: { donation: data }).parsed_response
  end

  def self.get_recipients
    get(get_account['donations_uri']).parsed_response
  end

  def self.get_donations
    get(get_account['recipients_uri']).parsed_response
  end
end
