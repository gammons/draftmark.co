console.log("here");
var index = function() {
  console.log("index");
}

var viewNote = function() {
  console.log("viewNote");
}
var routes = {
  '/index': index,
  '/notes/:id': viewNote
}
var router = Router(routes);
router.init();
