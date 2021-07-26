require('summernote/summernote.js');

const SUMMERNOTE_SELECTOR = '[data-type="summernote"]';

$(document).on('turbolinks:before-cache', () => {
  window.CDMS.summernote.destroy();
});

$(document).on('turbolinks:load', () => {
  window.CDMS.summernote.init();
});

window.CDMS.summernote = {};

window.CDMS.summernote.init = () => {
  $(SUMMERNOTE_SELECTOR).summernote({ minHeight: 250 });
};

window.CDMS.summernote.destroy = () => {
  $(SUMMERNOTE_SELECTOR).summernote('destroy');
};
