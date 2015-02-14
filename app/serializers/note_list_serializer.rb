class NoteListSerializer < ActiveModel::Serializer
  attributes :id, :title, :path

  def title
    object.title.gsub(/# /,'')
  end
end
