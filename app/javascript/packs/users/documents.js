let variables = []

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
  window.CDMS.document.variables.hideErrorName(page)
  window.CDMS.document.variables.hideErrorIdentifier(page)

  page.find('button#add_variable').on('click', () => {
    const name = page.find('input#variable_name').val();
    const identifier = page.find('input#variable_identifier').val();

    if (validate.validateName(name) && validate.validateIdentifier(identifier)) {
      window.CDMS.document.variables.hideErrorName(page)
      window.CDMS.document.variables.hideErrorIdentifier(page)

      let nameExists = variables.filter((e) => {return e.name == name})
      let identifierExists = variables.filter((e) => {return e.identifier == identifier})

      if (nameExists.length > 0 && nameExists[0].name == name && identifierExists.length > 0 && identifierExists[0].identifier == identifier) {
        alert("Essa variavel já existe.")
      } else {
        variables.push({"name": name, "identifier": identifier})
        window.CDMS.document.variables.addVariables(page, name, identifier)
      }

      window.CDMS.document.variables.updateField();
    } else if (!validate.validateName(name) && !validate.validateIdentifier(identifier)) {
      window.CDMS.document.variables.showErrorName(page)
      window.CDMS.document.variables.showErrorIdentifier(page)
    } else if (!validate.validateName(name)) {
      window.CDMS.document.variables.showErrorName(page)
      window.CDMS.document.variables.hideErrorIdentifier(page)
    } else {
      window.CDMS.document.variables.hideErrorName(page)
      window.CDMS.document.variables.showErrorIdentifier(page)
    }
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

window.CDMS.document.variables.showErrorName = (page) => {
  page.find('label#name-error').show()
}

window.CDMS.document.variables.showErrorIdentifier = (page) => {
  page.find('label#identifier-error').show()
}

window.CDMS.document.variables.hideErrorName = (page) => {
  page.find('label#name-error').hide()
}

window.CDMS.document.variables.hideErrorIdentifier = (page) => {
  page.find('label#identifier-error').hide()
}

window.CDMS.document.variables.addVariables = (page, name, identifier) => {
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
}

const regex = /[\s{}@!#$%^&*()/\\]/g;

const validate = {
  validateName(name) {
    if (name && !regex.test(name)) {
      return true;
    }
    return false;
  },
  validateIdentifier(identifier) {
    if (identifier && !regex.test(identifier)) {
      return true;
    }
    return false;
  }
}