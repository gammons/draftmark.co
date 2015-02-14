require 'test_helper'

class NoteTest < ActiveSupport::TestCase
  let(:content) { "# 2 oct 201
                  3\n\n**Talk with martin**\n\n- utilize fogbug'z burndown chart functionality.  must be able to close tickets quickly\n- brandon made a staging manager, can we fold that in?\n-
                  [https://pipelinedeals.fogbugz.com/default.asp?33226#227305](https://pipelinedeals.fogbugz.com/default.asp?33226#227305) - get this shit off the milestone  \n\n- [https://pipel
                  inedeals.fogbugz.com/default.asp?33720](https://pipelinedeals.fogbugz.com/default.asp?33720) - excel character problem.  wat do?  \n\n  \n  \n\nGrant\n\n- ~~[https://github.com
                  /PipelineDeals/pipeline\\_deals/pull/1643/files](https://github.com/PipelineDeals/pipeline_deals/pull/1643/files) - review and accept bigger PR~~  \n\n- ~~[https://github.com/P
                  ipelineDeals/pipeline\\_deals/pull/1665](https://github.com/PipelineDeals/pipeline_deals/pull/1665) - fix browser spec issue~~  \n\n- ~~see if snapshot finished saving of utf8
                  db~~\n- ~~attach new snapshot to hi db server~~\n[x]1.9.3 get up-to-date, [x]1.9.3 specs passing  \n[]PRs assigned to adrian, needs to be managed better  \n[x]database pruner i
                  s not running[]research dead man's snitch?[]lear\xEF\xBB\xBFn how hubot works and create a PR deadbeat thing  \n[]make sure adrian has enough work  \n\n  \n  \n\n**Brandon**\n\
                  n- Ticket monkey\n- Ansible \n- ~~stage manager -- added mutexes~~\n\n* * *\n  \n  \n\n  \n  \n\n  \n  \n\n" }

  test "it creates a title from the content" do
    note = Note.create(content: content, user: users(:bob))
    note.title.must_equal "2 oct 201"
  end
end
