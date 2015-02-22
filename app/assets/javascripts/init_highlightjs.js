var languageOverrides = {
  js: 'javascript',
  html: 'xml'
}
marked.setOptions({
  highlight: function(code, lang){
    if (typeof(lang) == "undefined") {
      return hljs.highlightAuto(code).value;
    } else {
      if(languageOverrides[lang]) lang = languageOverrides[lang];
      return _.includes(hljs.listLanguages(),lang) ? hljs.highlight(lang, code).value : code;
    }
  }
});
//
