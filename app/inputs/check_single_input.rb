# <div>
#   <label class="row">
#     <span class="col">SMS Notifications</span>
#     <span class="col-auto">
#       <label class="form-check form-check-single form-switch">
#         <input class="form-check-input" type="checkbox">
#       </label>
#     </span>
#   </label>
# </div>

class CheckSingleInput < SimpleForm::Inputs::Base
  def input(_wrapper_options)
    template.tag.label(class: 'row') do
      template.concat span_tag
      template.concat label_form
    end
  end

  def label_form
    template.tag.span(class: 'col-auto') do
      template.tag.label(class: 'custom-switch') do
        template.concat @builder.check_box(attribute_name, class: 'custom-switch-input')
        template.concat span_indicator
      end
    end
  end

  def span_tag
    field_name = options[:field_name] ||= object.class.human_attribute_name(attribute_name)

    template.tag.span(class: 'col') do
      field_name
    end
  end

  def span_indicator
    template.tag.span(class: 'custom-switch-indicator')
  end

  def label(_wrapper_options)
    ''
  end
end
