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
  window.CDMS.document.variables.addDefaultVariable(page);
};

window.CDMS.document.variables.submit = (page) => {
  page.find('button#add_variable').on('click', () => {
    const name = page.find('input#variable_name').val();
    const identifier = page.find('input#variable_identifier').val();

    window.CDMS.validations.validate({
      success: () => {
        const links = `<a data-variable-to-add="${identifier}" href="#">
                              <i class="fas fa-plus icon" data-toggle="tooltip" data-original-title="Adicionar variável no texto"></i>
                            </a>
                            <a>
                             <i class="fas fa-trash icon"></i>
                            </a>`;
        const row = `<tr>
                      <td>${name}</td>
                      <td>${identifier}</td>
                      <td>${links}</td>
                    </tr>`;

        page.find('table#variables-table tbody').append(row);
        $('#add_variables_modal').modal('hide');
        page.find('input#variable_name').val('');
        page.find('input#variable_identifier').val('');
        window.CDMS.document.variables.updateField();
      },
      error: () => { },
    });
  });
};

window.CDMS.document.variables.addDefaultVariable = (page) => {
  let lastSummer;
  const ids = 'table#default-variables-table tbody, table#variables-table tbody';

  page.find(ids).on('click', 'tr td:last-child a:first-child', function addVariableToCD() {
    const defaultVariable = $(this).data('variable-to-add');
    const toInsert = `{${defaultVariable}}`;

    $(`#document_${lastSummer}`).summernote('editor.saveRange');
    $(`#document_${lastSummer}`).summernote('editor.restoreRange');
    $(`#document_${lastSummer}`).summernote('editor.focus');
    $(`#document_${lastSummer}`).summernote('editor.insertText', toInsert);

    return false;
  });

  $('#document_front_text').on('summernote.mouseup', () => {
    lastSummer = 'front_text';
  });
  $('#document_back_text').on('summernote.mouseup', () => {
    lastSummer = 'back_text';
  });
};

window.CDMS.document.variables.remove = (page) => {
  page.find('table#variables-table tbody').on('click', 'tr td:last-child a:last-child', function removeVariable() {
    $(this).parent().parent().remove();
    window.CDMS.document.variables.updateField();
  });
};

window.CDMS.document.variables.updateField = () => {
  const variables = [];
  const rows = $('table#variables-table tbody tr');
  rows.each(function buildRow() {
    const name = $(this).find('td:first').text();
    const identifier = $(this).find('td:nth-child(2)').text();

    const row = { name, identifier };

    variables.push(row);
  });

  $('input#document_variables').val(JSON.stringify(variables));
};
