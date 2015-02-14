class DropboxSyncWorker
  include Sidekiq::Worker

  class DropboxEntry
    attr_reader :path, :attrs
    def initialize(arr)
      @path = arr[0]
      @attrs = arr[1]
    end

    def dir?
      @attrs["is_dir"]
    end

    def mtime
      @attrs["client_mtime"]
    end
  end

  def perform(user:, client:)
    @delta = client.delta(user.dropbox_cursor)
    done = false

    while !done
      @delta["entries"].each do |entry|
        entry = DropboxEntry.new(entry)
        next if entry.dir?
        note = user.notes.where(path: entry.path).first
        file = client.get_file_and_metadata(entry.path)

        if note
          note.update_attributes(content: file[0], path: entry.path, mtime: entry.mtime)
        else
          user.notes.create(content: file[0], path: entry.path, mtime: entry.mtime)
        end
      end

      user.update_attributes(dropbox_cursor: @delta["cursor"])
      done = !@delta["has_more"]
    end
  end
end
