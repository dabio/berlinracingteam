(function() {
  var add_current_person, prepare_emails, remove_current_person;

  prepare_emails = function() {
    var email, email_el;
    email_el = $('#email');
    email = email_el.text().replace(' . ', '.').replace(' [at] ', '@');
    email_el.attr('href', "mailto:" + email);
    return email_el.text(email);
  };

  add_current_person = function(resp) {
    var count, tmpl;
    count = $("#" + resp.id + " ul.participants li").length;
    if (count === 0) {
      tmpl = $('#participants-li-first').html();
    } else {
      tmpl = $('#participants-li-more').html();
    }
    return $("#" + resp.id + " ul.participants li").first().prepend(tmpl);
  };

  remove_current_person = function(resp) {
    return $("#" + resp.id + " ul.participants li.me").remove();
  };

  $.domReady(function() {
    prepare_emails();
    return $('input.participation').click(function() {
      var checked;
      checked = this.checked;
      return $.ajax({
        url: this.value,
        method: checked ? 'post' : 'delete',
        type: 'json',
        contentType: 'json',
        success: function(resp) {
          if (checked) {
            return add_current_person(resp);
          } else {
            return remove_current_person(resp);
          }
        }
      });
    });
  });

}).call(this);
