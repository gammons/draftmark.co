class NotesController < ApplicationController
  before_action :authenticate_user!

  def index
    respond_to do |format|
      format.json do 
        @notes = current_user.notes.order("mtime desc").limit(50)
        render json: @notes, each_serializer: NoteListSerializer, root: false
      end
    end
  end

  def content
    respond_to do |format|
      format.json do 
        @notes = current_user.notes.find(params[:id])
        render json: @notes, serializer: NoteContentSerializer, root: false
      end
    end
  end
end
