class DropboxController < ApplicationController
  before_action :authenticate_user!, except: [:webhook, :webhook_challenge]
  protect_from_forgery except: :webhook

  def index
  end

  def authorize
    authorize_url = web_auth.start()
    redirect_to authorize_url
  end

  def redirect
    begin
      access_token, user_id, url_state = web_auth.finish(params)
      client = DropboxClient.new(access_token)
      dropbox_user_id = client.account_info["uid"]
      current_user.update_attributes(dropbox_access_token: access_token, dropbox_user_id: dropbox_user_id)
      perform_sync
      redirect_to action: :index
    rescue DropboxOAuth2Flow::BadRequestError => e
      render text: "<p>Bad request to /dropbox-auth-finish: #{e}</p>"
    rescue DropboxOAuth2Flow::BadStateError => e
      render text: "<p>Auth session expired: #{e}</p>"
    rescue DropboxOAuth2Flow::CsrfError => e
      logger.info("/dropbox-auth-finish: CSRF mismatch: #{e}")
      render text: "<p>CSRF mismatch</p>"
    rescue DropboxOAuth2Flow::NotApprovedError => e
      render text: "<p>Not approved?  Why not, bro?</p>"
    rescue DropboxOAuth2Flow::ProviderError => e
      render text: "Error redirect from Dropbox: #{e}"
    rescue DropboxError => e
      render text: "<p>Error getting access token</p>"
    end
  end

  def webhook_challenge
    render text: params[:challenge]
  end

  def webhook
    params[:delta][:users].each do |id|
      perform_sync(user: User.find_by_dropbox_user_id(id))
    end
    render nothing: true
  end

  private

  def web_auth
    DropboxOAuth2Flow.new(ENV['DROPBOX_KEY'], ENV['DROPBOX_SECRET'], redirect_url, session, :dropbox_auth_csrf_token)
  end

  def perform_sync(user: current_user)
    client = DropboxClient.new(user.dropbox_access_token)
    DropboxSyncWorker.perform_async(user_id: user.id)
  end
end
