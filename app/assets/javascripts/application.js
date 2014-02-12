//= require jquery
//= require jquery_ujs
//= require jquery.ui.datepicker
//= require jquery.turbolinks
//= require turbolinks
//= require lib/bootstrap.min
//= require forma
$(function() {
  $('.datepicker').datepicker({ dateFormat: 'dd-M-yy', changeMonth: true, changeYear: true, yearRange: "-100:+0" });
});