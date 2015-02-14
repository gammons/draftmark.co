require 'test_helper'

class FakeClient
  attr_accessor :delta_returns, :get_file_returns
  def delta(cursor)
    @delta_returns
  end

  def get_file_and_metadata(file)
    @get_file_returns || ["asdf"]
  end
end

class DropboxSyncWorkerTest < ActiveSupport::TestCase
  let(:user) { User.first }
  let(:client) do
    c = FakeClient.new
    c.delta_returns = {"has_more"=>false, "cursor"=>"AAFu4mL4H5kkDv-jCmpBglpe6stXtc_nGwiO1ly2eRTIEEkkRUrf7pSmp9KmUqH46ouDsH6IIaax57qAOOksCcVBparq_154o_lKSV9hVLgsvJmDY1Z8XsJFHZRDvKtHKVxR_5j10sPwKeM0v3AVOfgiUSL7LezkU-RiamBfYvRlyw", "entries"=>[["/notes/test/ass.md", {"rev"=>"68c3d02639907", "thumb_exists"=>false, "path"=>"/notes/test/ass.md", "is_dir"=>false, "client_mtime"=>"Sat, 14 Feb 2015 15:02:38 +0000", "icon"=>"page_white_text", "read_only"=>false, "modifier"=>nil, "bytes"=>27, "modified"=>"Sat, 14 Feb 2015 15:02:40 +0000", "size"=>"27 bytes", "root"=>"dropbox", "mime_type"=>"application/octet-stream", "revision"=>429117}]], "reset"=>false}
    c
  end
  it "updates the cursor after a run" do
    user.reload.dropbox_cursor.must_be :==, nil
    DropboxSyncWorker.new.perform(user: user, client: client)
    user.reload.dropbox_cursor.must_be :!=, nil
  end

  describe "adding a note" do
    let(:client) do
      c = FakeClient.new
      c.delta_returns = {"has_more"=>false, "cursor"=>"AAFu4mL4H5kkDv-jCmpBglpe6stXtc_nGwiO1ly2eRTIEEkkRUrf7pSmp9KmUqH46ouDsH6IIaax57qAOOksCcVBparq_154o_lKSV9hVLgsvJmDY1Z8XsJFHZRDvKtHKVxR_5j10sPwKeM0v3AVOfgiUSL7LezkU-RiamBfYvRlyw", "entries"=>[["/notes/test/newnote.md", {"rev"=>"68c3d02639907", "thumb_exists"=>false, "path"=>"/notes/test/newnote.md", "is_dir"=>false, "client_mtime"=>"Sat, 14 Feb 2015 15:02:38 +0000", "icon"=>"page_white_text", "read_only"=>false, "modifier"=>nil, "bytes"=>27, "modified"=>"Sat, 14 Feb 2015 15:02:40 +0000", "size"=>"27 bytes", "root"=>"dropbox", "mime_type"=>"application/octet-stream", "revision"=>429117}]], "reset"=>false}
      c.get_file_returns = ["# ass\n\nthis is an ass file\n", {"rev"=>"68c3d02639907", "thumb_exists"=>false, "path"=>"/notes/test/newnote.md", "is_dir"=>false, "client_mtime"=>"Sat, 14 Feb 2015 15:02:38 +0000", "icon"=>"page_white_text", "read_only"=>false, "modifier"=>nil, "bytes"=>27, "modified"=>"Sat, 14 Feb 2015 15:02:40 +0000", "size"=>"27 bytes", "root"=>"dropbox", "mime_type"=>"application/octet-stream", "revision"=>429117}]
      c
    end
    let(:note) { Note.last }

    it "adds the file to the database" do
      previous_count = Note.count
      DropboxSyncWorker.new.perform(user: user, client: client)
      Note.count.must_equal(previous_count + 1)
    end

    it "adds the note with the correct attributes" do
      DropboxSyncWorker.new.perform(user: user, client: client)
      note.path.must_equal("/notes/test/newnote.md")
      note.mtime.must_be :!=, nil
    end
  end

  describe "updating a file" do
    let(:existing_note) { notes(:ass) }
    let(:client) do
      c = FakeClient.new
      c.delta_returns = {"has_more"=>false, "cursor"=>"AAG9lDM3D-xxZJXUOw1frz8GutMFoKCNZV7XmyKXjM6mumqCyO5YITFPJYQI_eGHINHpLYB1a3M8ERBVdBxLZvYnNW8F4ICemMWsxWdHmdPdfOS_ERg8qJtJwVdZqS0iTjOLX07I_Jh8nJYdvFIpeuK-4MsoCPbhEcXDRketRzon0Q", "entries"=>[["/notes/test/ass.md", {"rev"=>"68c4002639907", "thumb_exists"=>false, "path"=>"/notes/test/ass.md", "is_dir"=>false, "client_mtime"=>"Sat, 14 Feb 2015 18:57:07 +0000", "icon"=>"page_white_text", "read_only"=>false, "modifier"=>nil, "bytes"=>67, "modified"=>"Sat, 14 Feb 2015 18:57:09 +0000", "size"=>"67 bytes", "root"=>"dropbox", "mime_type"=>"application/octet-stream", "revision"=>429120}]], "reset"=>false}
      c.get_file_returns = ["# ass\n\nthis is an ass file\n\nI just changed ass\n\nI changed it again\n", {"rev"=>"68c4002639907", "thumb_exists"=>false, "path"=>"/notes/test/ass.md", "is_dir"=>false, "client_mtime"=>"Sat, 14 Feb 2015 18:57:07 +0000", "icon"=>"page_white_text", "read_only"=>false, "modifier"=>nil, "bytes"=>67, "modified"=>"Sat, 14 Feb 2015 18:57:09 +0000", "size"=>"67 bytes", "root"=>"dropbox", "mime_type"=>"application/octet-stream", "revision"=>429120}]
      c
    end

    it "updates the note" do
      old_content = existing_note.content
      DropboxSyncWorker.new.perform(user: user, client: client)
      existing_note.reload.content.must_be :!=, old_content
    end

    it "does not create a new note" do
      old_count = Note.count
      DropboxSyncWorker.new.perform(user: user, client: client)
      Note.count.must_equal old_count
    end
  end

  describe "deleting a file" do
    let(:client) do
      c = FakeClient.new
      c.delta_returns = {"has_more"=>false, "cursor"=>"AAE1K1u0i16eI_6IjkgqZbs6OZ6mVLG9QZ504Jo7pGsiQVKeGRVgo2oZwRvB6GFJOF1u966ewE2hkoCKj8Tqd272-bJ6kFtl5wWJqvHyX1QCVmtHXUvW9qD9j0x8oAtVikdbrLsp8kvOtLqfbin5VkiiS4l9F-lTWeMM48tEZe2A8A", "entries"=>[["/notes/test/ass.md", nil]], "reset"=>false}
      c
    end

    it "removes the note from the db" do
      old_count = Note.count
      DropboxSyncWorker.new.perform(user: user, client: client)
      Note.count.must_equal (old_count - 1)
    end
  end
end
