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
    console.log("content =", this.state.content);
    var rawMarkup = marked(this.state.content.toString());
    return(
      <div>
        <span dangerouslySetInnerHTML={{__html: rawMarkup}} />
      </div>
    );
  }
});
