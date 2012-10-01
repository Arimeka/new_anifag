function moreButton(obj, event, key)
{
  $('#more').remove();
  $('#content').insertHtml('<hr id="more">').getText();
}

$(document).ready(
  function(){
  var csrf_token = $('meta[name=csrf-token]').attr('content');
  var csrf_param = $('meta[name=csrf-param]').attr('content');
  var params;
  if (csrf_param !== undefined && csrf_token !== undefined) {
    params = csrf_param + "=" + encodeURIComponent(csrf_token);
  }
  $('.redactor_article').redactor(
    { lang: 'ru',
      focus: true,
      autoresize: false,
      buttonsAdd: ['|', 'button1'], 
      buttonsCustom: {
        button1: {
          title: 'More', 
          callback: moreButton 
        } 
      },
      "imageUpload":"/redactor_rails/pictures?" + params,
      "imageGetJson":"/redactor_rails/pictures",
      "path":"/assets/redactor-rails",
      "css":"style.css"}
  );
  
  $('.redactor_topic').redactor({
      lang: 'ru',
      focus: true,
      autoresize: false,
      buttons: ['formatting', '|', 'bold', 'italic', 'deleted', '|',
                'unorderedlist', 'orderedlist', 'outdent', 'indent', '|',
                'image', 'video', 'file', 'table', 'link', '|',
                'fontcolor', 'backcolor', '|', 
                'alignleft', 'aligncenter', 'alignright', 'justify', '|',
                'horizontalrule']    
    }); 
});
