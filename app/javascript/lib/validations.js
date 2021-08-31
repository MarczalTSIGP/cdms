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

window.CDMS.validations.regex = () => window.CDMS.validations.baseValidator({
  validatorName: 'regex',
  defaultMessage: 'padrão não aceito',
  validator: (input) => {
    const regexString = input.data('validations-regex');
    const normalizeRegex = regexString.match(/^\/(.*)(\/(.*))$/);
    const regex = new RegExp(normalizeRegex[1], normalizeRegex[3]);

    return regex.test(input.val());
  },
});

window.CDMS.validations.defaultVariablesIdentifiers = () => window.CDMS.validations.baseValidator({
  validatorName: 'default-variables',
  defaultMessage: 'identificador padrão não permitido',
  validator: (input) => {
    const defaultVariables = input.data('validations-default-variables').split(',');
    return defaultVariables.includes(input.val());
  },
});

window.CDMS.validations.presence = () => window.CDMS.validations.baseValidator({
  validatorName: 'presence',
  defaultMessage: 'não pode ficar em branco',
  validator: (input) => (input.val().trim().length === 0),
});

window.CDMS.validations.uniquenessInJson = () => window.CDMS.validations.baseValidator({
  validatorName: 'uniqueness-in-json',
  defaultMessage: 'já está em uso',
  validator: (input) => {
    const jsonS = $(input.data('validations-uniqueness-in-json')).val();
    const json = JSON.parse(jsonS);

    return json.some((item) => item.identifier === input.val());
  },
});

window.CDMS.validations.baseValidator = (options) => {
  const inputs = $(`input[data-validations-${options.validatorName}]`);
  if (inputs.length === 0) return false;

  let hasErrors = false;
  inputs.each(function validate() {
    const input = $(this);
    const message = input.data(`validations-${options.validatorName}-message`) || options.defaultMessage;

    if (options.validator(input)) {
      window.CDMS.validations.utils.displayError(input, options.validatorName, message);
      hasErrors = true;
    } else {
      window.CDMS.validations.utils.removeDisplayedError(input, options.validatorName);
    }
  });

  return hasErrors;
};

window.CDMS.validations.utils.displayError = (element, validator, message) => {
  const error = `<div class="invalid-feedback ${validator}-validator">
                    ${message}
                 </div>`;

  window.CDMS.validations.utils.removeDisplayedError(element, validator);

  element.addClass(`is-invalid ${validator}-validator`);
  element.parent().append(error);
};

window.CDMS.validations.utils.removeDisplayedError = (element, validator) => {
  if (element.hasClass(`${validator}-validator`)) {
    element.removeClass('is-invalid');
    element.removeClass('{validator}-validator');
  }

  element.next(`div.invalid-feedback.${validator}-validator`).remove();
};
