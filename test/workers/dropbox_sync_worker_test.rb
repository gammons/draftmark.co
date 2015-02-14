require 'test_helper'

class FakeClient
  attr_accessor :delta_returns, :get_file_returns
  def delta(cursor)
    @delta_returns
  end

  def get_file_and_metadata(file)
    @get_file_returns
  end
end

class DropboxSyncWorkerTest < ActiveSupport::TestCase

  describe "adding a file" do
    let(:user) { User.first }
    let(:client) do
      c = FakeClient.new
      c.delta_returns = {"has_more"=>false, "cursor"=>"AAFu4mL4H5kkDv-jCmpBglpe6stXtc_nGwiO1ly2eRTIEEkkRUrf7pSmp9KmUqH46ouDsH6IIaax57qAOOksCcVBparq_154o_lKSV9hVLgsvJmDY1Z8XsJFHZRDvKtHKVxR_5j10sPwKeM0v3AVOfgiUSL7LezkU-RiamBfYvRlyw", "entries"=>[["/notes/test/ass.md", {"rev"=>"68c3d02639907", "thumb_exists"=>false, "path"=>"/notes/test/ass.md", "is_dir"=>false, "client_mtime"=>"Sat, 14 Feb 2015 15:02:38 +0000", "icon"=>"page_white_text", "read_only"=>false, "modifier"=>nil, "bytes"=>27, "modified"=>"Sat, 14 Feb 2015 15:02:40 +0000", "size"=>"27 bytes", "root"=>"dropbox", "mime_type"=>"application/octet-stream", "revision"=>429117}]], "reset"=>false}
      c.get_file_returns = ["# ass\n\nthis is an ass file\n", {"rev"=>"68c3d02639907", "thumb_exists"=>false, "path"=>"/notes/test/ass.md", "is_dir"=>false, "client_mtime"=>"Sat, 14 Feb 2015 15:02:38 +0000", "icon"=>"page_white_text", "read_only"=>false, "modifier"=>nil, "bytes"=>27, "modified"=>"Sat, 14 Feb 2015 15:02:40 +0000", "size"=>"27 bytes", "root"=>"dropbox", "mime_type"=>"application/octet-stream", "revision"=>429117}]
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
      note.path.must_equal("/notes/test/ass.md")
    end

    it "updates the cursor" do
      user.reload.dropbox_cursor.must_be :==, nil
      DropboxSyncWorker.new.perform(user: user, client: client)
      user.reload.dropbox_cursor.must_be :!=, nil

    end
  end
  describe "updating a file" do

  end
  describe "deleting a file" do

  end
end
# describe DropboxSyncWorker < ActiveSupport::TestCase do
#   let(:user) { User.first }
#   let(:client) { FakeClient.new }
#
#   describe "adding a file" do
#     it "adds the file to the database" do
#       byebug
#       client.delta_returns = {"has_more"=>false, "cursor"=>"AAFu4mL4H5kkDv-jCmpBglpe6stXtc_nGwiO1ly2eRTIEEkkRUrf7pSmp9KmUqH46ouDsH6IIaax57qAOOksCcVBparq_154o_lKSV9hVLgsvJmDY1Z8XsJFHZRDvKtHKVxR_5j10sPwKeM0v3AVOfgiUSL7LezkU-RiamBfYvRlyw", "entries"=>[["/notes/test/ass.md", {"rev"=>"68c3d02639907", "thumb_exists"=>false, "path"=>"/notes/test/ass.md", "is_dir"=>false, "client_mtime"=>"Sat, 14 Feb 2015 15:02:38 +0000", "icon"=>"page_white_text", "read_only"=>false, "modifier"=>nil, "bytes"=>27, "modified"=>"Sat, 14 Feb 2015 15:02:40 +0000", "size"=>"27 bytes", "root"=>"dropbox", "mime_type"=>"application/octet-stream", "revision"=>429117}]], "reset"=>false}
#       client.get_file_returns = ["# ass\n\nthis is an ass file\n", {"rev"=>"68c3d02639907", "thumb_exists"=>false, "path"=>"/notes/test/ass.md", "is_dir"=>false, "client_mtime"=>"Sat, 14 Feb 2015 15:02:38 +0000", "icon"=>"page_white_text", "read_only"=>false, "modifier"=>nil, "bytes"=>27, "modified"=>"Sat, 14 Feb 2015 15:02:40 +0000", "size"=>"27 bytes", "root"=>"dropbox", "mime_type"=>"application/octet-stream", "revision"=>429117}]
#
#       DropboxSyncWorker.new.perform(user: user, client: client)
#
#     end
#   end
# end
