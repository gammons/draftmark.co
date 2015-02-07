class DropboxController < ApplicationController
  before_action :authenticate_user!

  def index
    render text: "Yup you have found the index"
  end

  def authorize
    authorize_url = web_auth.start()
    redirect_to authorize_url
  end

  def redirect
    begin
      access_token, user_id, url_state = web_auth.finish(params)
      current_user.update_attributes(dropbox_access_token: access_token)
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

  private

  def web_auth
    DropboxOAuth2Flow.new(ENV['DROPBOX_KEY'], ENV['DROPBOX_SECRET'], redirect_url, session, :dropbox_auth_csrf_token)
  end
end
