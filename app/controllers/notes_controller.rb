class NotesController < ApplicationController
  before_action :authenticate_user!

  def index
    respond_to do |format|
      format.json do 
        @notes = current_user.notes.limit(50)
        render json: @notes
      end
    end
  end
end
