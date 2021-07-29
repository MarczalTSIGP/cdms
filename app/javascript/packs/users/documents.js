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
    const regexForName = /[@!#$%^&*()/\\]/g;
    const regexForIdentifier = /[{}@!#$%^&*()\s/\\]/g;

    const name = page.find('input#variable_name').val();
    const identifier = page.find('input#variable_identifier').val();

    const nameIsValid = regexForName.test(name)
    const identifierIsValid = regexForIdentifier.test(identifier)

    if (!nameIsValid && !identifierIsValid) {
      window.CDMS.document.variables.hideErrorName(page)
      window.CDMS.document.variables.hideErrorIdentifier(page)

      let namesInTable = variables.filter((e) => {return e.name == name})
      let identifierInTable = variables.filter((e) => {return e.identifier == identifier}) 

      if (validateNameExists(namesInTable, name) && validateIdentifierExists(identifierInTable, identifier)) {
        alert("Essa variavel já existe.")
      } else {
        variables.push({"name": name, "identifier": identifier})
        window.CDMS.document.variables.addVariables(page, name, identifier)
      }

      window.CDMS.document.variables.updateField();
    } else if (nameIsValid && identifierIsValid) {
      window.CDMS.document.variables.showErrorName(page)
      window.CDMS.document.variables.showErrorIdentifier(page)
    } else if (nameIsValid) {
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



function validateName(name) {
  if (name && !regexForName.test(name)) {
    return true;
  }

  return false;
}

function validateIdentifier(identifier) {
  if (identifier && !regexForIdentifier.test(identifier)) {
    return true;
  }

  return false;
}

const validateNameExists = (namesInTable, name) => {
  let isValid = false
  if (namesInTable.length > 0 && namesInTable[0].name == name) {
    isValid = true
  }

  return isValid
}

const validateIdentifierExists = (identifierInTable, identifier) => {
  let isValid = false
  if (identifierInTable.length > 0 && identifierInTable[0].name == identifier) {
    isValid = true
  }

  return isValid
}