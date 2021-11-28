# <label class="custom-switch">
#   <input type="checkbox" name="custom-switch-checkbox" class="custom-switch-input">
#   <span class="custom-switch-indicator"></span>
#   <span class="custom-switch-description">I agree with terms and conditions</span>
# </label>
class SwitchSingleInput < SimpleForm::Inputs::Base
  def input(_wrapper_options)
    template.tag.label(class: 'custom-switch pl-0 mt-3') do
      template.concat @builder.check_box(attribute_name, class: 'custom-switch-input')
      template.concat span_description_true
      template.concat span_indicator
      template.concat span_description_false
    end
  end

  def span_indicator
    template.tag.span(class: 'custom-switch-indicator')
  end

  def span_description_true
    template.tag.span(class: 'custom-switch-description custom-switch-description-active mr-1') do
      t("activerecord.attributes.#{object.model_name.name.downcase}.#{attribute_name}_boolean.true")
    end
  end

  def span_description_false
    template.tag.span(class: 'custom-switch-description custom-switch-description-unactive') do
      t("activerecord.attributes.#{object.model_name.name.downcase}.#{attribute_name}_boolean.false")
    end
  end

  def label(_wrapper_options)
    template.tag.div(class: 'form-label font-weight-normal') do
      object.class.human_attribute_name(attribute_name)
    end
  end
end
