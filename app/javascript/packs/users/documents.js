$(document).on('turbolinks:load', () => {
  window.CDMS.document.init();
});

window.CDMS.document = {};
window.CDMS.document.variables = {};

window.CDMS.document.init = () => {
  const page = $('#documents-edit, #documents-update, #documents-new, #documents-create');
  if (page.length === 0) return;

  window.CDMS.document.variables.submit(page);
  window.CDMS.document.variables.remove(page);
};

window.CDMS.document.variables.submit = (page) => {
  page.find('button#add_variable').on('click', () => {
    const name = page.find('input#variable_name').val();
    const identifier = page.find('input#variable_identifier').val();

    page.find('input#variable_name').val('');
    page.find('input#variable_identifier').val('');

    const removeLink = `<a>
                           <i class="fas fa-trash icon"></i>
                        </a>`;
    const row = `<tr>
                   <td>${name}</td>
                   <td>${identifier}</td>
                   <td>${removeLink}</td>
                 </tr>`;

    page.find('table#variables-table tbody').append(row);

    $('#add_variables_modal').modal('hide');

    window.CDMS.document.variables.updateField();
  });
};

window.CDMS.document.variables.remove = (page) => {
  page.find('table#variables-table tbody').on('click', 'tr td:last-child a', function () {
    $(this).parent().parent().remove();
    window.CDMS.document.variables.updateField();
  });
};

window.CDMS.document.variables.updateField = () => {
  const variables = [];
  const rows = $('table#variables-table tbody tr');

  rows.each(function () {
    const name = $(this).find('td:first').text();
    const identifier = $(this).find('td:nth-child(2)').text();

    const row = { name, identifier };

    variables.push(row);
  });

  $('input#document_variables').val(JSON.stringify(variables));
};
