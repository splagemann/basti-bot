class MessagesController < ApplicationController
  def index
    if hub_params.fetch('hub.mode', '') == 'subscribe' &&
       hub_params.fetch('hub.verify_token', '') == ENV.fetch('VERIFY_TOKEN')
      render plain: hub_params.fetch('hub.challenge', '')
    else
      render plain: ''
    end
  end

  private

  def hub_params
    params.permit('hub.challenge', 'hub.mode', 'hub.verify_token')
  end
end
