class NoteListSerializer < ActiveModel::Serializer
  attributes :id, :title, :path
end
