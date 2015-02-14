var IndexView = React.createClass({
  getInitialState: function() {
    return {notes: [], router:  null, view: 'index' }
  },

  componentDidMount: function() {

    var _this = this;
    $.ajax({
      url: "/notes.json",
      dataType: 'json',
      success: function(data) {
        this.setState({notes: data, view:  this.state.view});
        this.setupRouter();
      }.bind(this),
      error: function(xhr, status, err) {
        console.error(this.props.url, status, err.toString());
      }.bind(this)
    });
  },

  setupRouter: function() {
    var routes = {
      '/': this.indexView,
      '/notes/:id': this.viewNoteView
    }
    var router = Router(routes);
    router.init();

    this.setState({notes: this.state.notes, router: router});
  },
  indexView: function() {
    console.log("route to indexView");
    this.setState({notes: this.state.notes, router: this.state.router, view: "index"});
  },
  viewNoteView: function(id) {
    console.log("route to noteView");
    this.setState({notes: this.state.notes, router: this.state.router, view: "note", selectedNoteId: id});
  },

  render: function() {
    if (this.state.view == 'index') {
      return this.renderIndex();
    } else if (this.state.view == 'note') {
      return this.renderNote();
    }
  },

  renderIndex: function() {
    var showNote = this.showNote;
    var notes = _.map(this.state.notes, function(note) {
      return(
        <li key={note.id}>
          <NoteCardView className="noteCardView" id={note.id} title={note.title} content={note.content} clickNote={showNote} />
        </li>
      );
    });

    return(
      <div>
        <h1>Notes</h1>
        <ul className="small-block-grid-2 medium-block-grid-4 large-block-grid-6">
          {notes}
        </ul>
      </div>
    );
  },

  renderNote: function() {
    var selectedNote = this.getNote(this.state.selectedNoteId);
    return (
      <NoteView id={selectedNote.id} title={selectedNote.title} content={selectedNote.content} />
    );
  },
  getNote: function(id) {
    return _.find(this.state.notes, function(note) { return note.id == id });
  }

});
