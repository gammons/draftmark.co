var NoteView = React.createClass({
  getInitialState: function() {
      return({content: ""});
  },
  componentDidMount: function() {
    var _this = this;
    $.ajax({
      url: "/notes/"+this.props.id+"/content.json",
      dataType: 'json',
      success: function(data) {
        this.setState({content: data.content});
      }.bind(this),
      error: function(xhr, status, err) {
        console.error(this.props.url, status, err.toString());
      }.bind(this)
    });
  },
  render: function() {
    var rawMarkup = marked(this.state.content.toString());
    return(
      <div>
        <a href="#">Back to notes list</a>
        <span dangerouslySetInnerHTML={{__html: rawMarkup}} />
      </div>
    );
  }
});
