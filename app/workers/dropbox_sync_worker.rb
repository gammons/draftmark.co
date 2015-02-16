class DropboxSyncWorker
  include Sidekiq::Worker

  class DropboxEntry
    attr_reader :path, :attrs
    def initialize(arr)
      @path = arr[0]
      @attrs = arr[1]
    end

    def deleted?
      @attrs.nil?
    end

    def dir?
      @attrs.nil? ? false : @attrs["is_dir"]
    end

    def mtime
      @attrs["client_mtime"]
    end
  end

  def perform(user_id:, client: nil)
    user = User.find user_id
    client ||= DropboxClient.new(user.dropbox_access_token)
    done = false
    changed = false

    while !done
      @delta = client.delta(user.dropbox_cursor)
      @delta["entries"].each do |entry|
        entry = DropboxEntry.new(entry)
        next if entry.dir? || !entry.path.ends_with?(".md")

        note = user.notes.where(path: entry.path).first
        if entry.deleted?
          if note
            note.destroy
            changed = true
          end
          next
        end

        changed = true
        file = client.get_file_and_metadata(entry.path)
        if note
          note.update_attributes(content: file[0], path: entry.path, mtime: entry.mtime)
        else
          user.notes.create(content: file[0], path: entry.path, mtime: entry.mtime)
        end
      end

      Pusher['updates'].trigger('update', { message: 'yup' }) if changed

      user.update_attributes(dropbox_cursor: @delta["cursor"])
      done = !@delta["has_more"]
    end
  end
end
