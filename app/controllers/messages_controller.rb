# frozen_string_literal: true

class MessagesController < ApplicationController
  skip_before_action :verify_authenticity_token

  before_action def log_request_headers
    return unless Rails.logger.debug?
    Rails.logger.debug '  Headers:'
    request.headers
           .to_h
           .select { |name, _| name.in?(ActionDispatch::Http::Headers::CGI_VARIABLES) || name =~ /^HTTP_/ }
           .transform_keys { |name| name.sub(/^HTTP_/, '').downcase.dasherize.gsub(/\b\w/, &:upcase) }
           .sort_by { |name, _| name }
           .each do |name, value|
      Rails.logger.debug "    #{name}: #{value}"
    end
  end

  def index
    if hub_params.fetch('hub.mode', '') == 'subscribe' &&
       hub_params.fetch('hub.verify_token', '') == ENV.fetch('VERIFY_TOKEN')
      render plain: hub_params.fetch('hub.challenge', '')
    else
      render plain: ''
    end
  end

  def handle_message
    msg = {
      recipient: {
        id: params[:sender][:id]
      },
      message: {
        text: params[:message][:text]
      }
    }

    url = ENV.fetch('API_URL')
    token = ENV.fetch('TOKEN')
    httparty.post url + token,
                  body: msg.to_json,
                  headers: { 'Content-Type' => 'application/json' }
    render plain: ''
  end

  private

  def hub_params
    params.permit('hub.challenge', 'hub.mode', 'hub.verify_token')
  end
end
