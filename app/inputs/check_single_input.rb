# From https://tabler.io/preview
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
      template.concat label_span_tag
      template.concat label_form
    end
  end

  # <span class="col-auto">
  #   <label class="custom-switch">
  #     <input class="custom-switch-input" type="checkbox">
  #   </label>
  # </span>
  def label_form
    template.tag.span(class: 'col-auto') do
      template.tag.label(class: 'custom-switch') do
        template.concat @builder.check_box(attribute_name, class: 'custom-switch-input')
        template.concat span_indicator
      end
    end
  end

  # <span class="col">SMS Notifications</span>
  def label_span_tag
    field_name = options[:field_name] ||= object.class.human_attribute_name(attribute_name)

    template.tag.span(class: 'col') do
      field_name
    end
  end

  # <span class="custom-switch-indicator"></span>
  # Show switch single style
  def span_indicator
    template.tag.span(class: 'custom-switch-indicator')
  end

  def label(_wrapper_options)
    ''
  end
end
