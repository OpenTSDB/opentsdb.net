// Load jquery first.  Assumes there will be a div named `toc'.
var toc_n = 0;
$(document).ready(function() {
  $("h2,h3,h4").each(function(i) {
    var q = $(this);
    var id = q.attr("id");
    if (!id) {
      id = q.text().replace(/[^\/\w\d]+/g, "_").replace(/_$/, "");
      if (!id) {
        id = "_" + toc_n++;
      }
      q.attr("id", id);
    }
    var indent = q.attr("tagName").substr(1) * 15;
    $("#toc").append("<a style='display:block;padding-left:" + indent
                     + "px' href='#" + id + "'>" + q.html() + "</a>");
  });
  $("#toc").prepend("<h4>Table of contents</h4>");
  // The navbar is really annoying when clicking on an anchor,
  // so let's make it stick at the top.
  $("header").css("position", "absolute");
});
