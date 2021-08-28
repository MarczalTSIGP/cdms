window.CDMS.validations = {};
window.CDMS.validations.utils = {};

window.CDMS.validations.validate = (options) => {
  const presenceInvalid = window.CDMS.validations.presence();
  const regexInvalid = window.CDMS.validations.regex();
  const uniquenessInJsonInvalid = window.CDMS.validations.uniquenessInJson();
  const defaultVariablesIdentifiersInvalid = window.CDMS.validations.defaultVariablesIdentifiers();

  if (presenceInvalid
    || regexInvalid
    || uniquenessInJsonInvalid
    || defaultVariablesIdentifiersInvalid) options.error();

  else options.success();
};

window.CDMS.validations.regex = () => {
  const inputs = $('input[data-validations-regex]');
  if (inputs.length === 0) return false;

  let hasErrors = false;
  inputs.each(function validate() {
    const validator = 'regex';
    const defaultMessage = 'padrão não aceito';

    const input = $(this);
    const message = input.data(`validations-${validator}-message`) || defaultMessage;

    const regexString = input.data(`validations-${validator}`);
    const normalizeRegex = regexString.match(/^\/(.*)(\/(.*))$/);
    const regex = new RegExp(normalizeRegex[1], normalizeRegex[3]);

    if (regex.test(input.val())) {
      window.CDMS.validations.utils.displayError(input, validator, message);
      hasErrors = true;
    } else {
      window.CDMS.validations.utils.removeDisplayedError(input, validator);
    }
  });

  return hasErrors;
};
window.CDMS.validations.defaultVariablesIdentifiers = () => {
  const inputs = $('input[data-validations-default-variables]');
  if (inputs.length === 0) return false;

  let hasErrors = false;
  inputs.each(function validate() {
    const validator = 'default-variables';
    const defaultMessage = 'identificador padrão não permitido';

    const input = $(this);
    const message = input.data(`validations-${validator}-message`) || defaultMessage;
    const defaultVariables = input.data('validations-default-variables').split(',');

    if (defaultVariables.includes(input.val())) {
      window.CDMS.validations.utils.displayError(input, validator, message);
      hasErrors = true;
    } else {
      window.CDMS.validations.utils.removeDisplayedError(input, validator);
    }
  });

  return hasErrors;
};

window.CDMS.validations.presence = () => {
  const inputs = $('input[data-validations-presence=true]');
  if (inputs.length === 0) return false;

  let hasErrors = false;
  inputs.each(function validate() {
    const validator = 'presence';
    const defaultMessage = 'não pode ficar em branco';

    const input = $(this);
    const message = input.data(`validations-${validator}-message`) || defaultMessage;

    if (input.val().trim().length === 0) {
      window.CDMS.validations.utils.displayError(input, validator, message);
      hasErrors = true;
    } else {
      window.CDMS.validations.utils.removeDisplayedError(input, validator);
    }
  });

  return hasErrors;
};

window.CDMS.validations.uniquenessInJson = () => {
  const inputs = $('input[data-validations-uniqueness-in-json]');
  if (inputs.length === 0) return false;

  let hasErrors = false;
  inputs.each(function validate() {
    const validator = 'uniqueness-in-json';
    const defaultMessage = 'já está em uso';

    const input = $(this);
    const message = input.data(`validations-${validator}-message`) || defaultMessage;

    const jsonS = $(input.data(`validations-${validator}`)).val();
    const json = JSON.parse(jsonS);
    if (json.some((item) => item.identifier === input.val())) {
      window.CDMS.validations.utils.displayError(input, validator, message);
      hasErrors = true;
    } else {
      window.CDMS.validations.utils.removeDisplayedError(input, validator);
    }
  });

  return hasErrors;
};

window.CDMS.validations.utils.removeDisplayedError = (element, validator) => {
  if (element.hasClass(`${validator}-validator`)) {
    element.removeClass('is-invalid');
    element.removeClass('{validator}-validator');
  }

  element.next(`div.invalid-feedback.${validator}-validator`).remove();
};

window.CDMS.validations.utils.displayError = (element, validator, message) => {
  const error = `<div class="invalid-feedback ${validator}-validator">
                    ${message}
                 </div>`;

  window.CDMS.validations.utils.removeDisplayedError(element, validator);

  element.addClass(`is-invalid ${validator}-validator`);
  element.parent().append(error);
};
