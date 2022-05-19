import 'bootstrap';

document.addEventListener('turbolinks:load', () => {
  $('[data-toggle="tooltip"]').tooltip({ container: '#main-content', boundary: 'window' });

  /** Function for collapse card */
  $('[data-toggle="card-collapse"]').on('click', (e) => {
    const $card = $(e.currentTarget).closest('div.card');

    $card.toggleClass('card-collapsed');

    e.preventDefault();
    return false;
  });
});
