class Note < ActiveRecord::Base
  belongs_to :user
  before_save :set_title

  private

  def set_title
    self.title = content.split("\n")[0].gsub(/# /,'')
  end
end
