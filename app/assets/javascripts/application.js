//= require jquery
//= require jquery.turbolinks
//= require jquery_ujs
//= require jquery.ui.datepicker
//= require turbolinks
//= require lib/bootstrap.min
//= require forma
//= require cocoon
$(function() {
  $('.datepicker').datepicker({ dateFormat: 'dd-M-yy', changeMonth: true, changeYear: true, yearRange: "-100:+0" });
});
