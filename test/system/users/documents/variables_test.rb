require 'application_system_test_case'

class VarablesTest < ApplicationSystemTestCase
  context 'variables' do
    setup do
      user = create(:user, :manager)
      @department = create(:department)
      @department.department_users.create(user: user, role: :responsible)

      login_as(user, as: :user)
      visit new_users_document_path
    end

    context 'new' do
      should 'add' do
        find('#add_variable_button').click
        fill_in 'variable_name', with: 'Student name'
        fill_in 'variable_identifier', with: 'student-name'
        find('#add_variable').click

        within('table#variables-table tbody') do
          assert_selector 'tr:nth-child(1) td:nth-child(1)', text: 'Student name'
          assert_selector 'tr:nth-child(1) td:nth-child(2)', text: 'student-name'
        end
      end

      should 'save' do
        document = build(:document)

        fill_in 'document_title', with: document.title

        find('#document_category-selectized').click
        find('.selectize-dropdown-content .option[data-value="declaration"]').click

        find('#document_department_id-selectized').click
        find(".selectize-dropdown-content .option[data-value='#{@department.id}']").click

        page.execute_script("document.getElementById('document_front_text').innerText = '#{document.front_text}'")
        page.execute_script("document.getElementById('document_back_text').innerText = '#{document.back_text}'")

        find('#add_variable_button').click
        fill_in 'variable_name', with: 'Student name'
        fill_in 'variable_identifier', with: 'student-name'
        find('#add_variable').click

        submit_form

        visit edit_users_document_path(Document.last)

        within('table#variables-table tbody') do
          assert_selector 'tr:nth-child(1) td:nth-child(1)', text: 'Student name'
          assert_selector 'tr:nth-child(1) td:nth-child(2)', text: 'student-name'
          assert_selector 'tr:nth-child(1) td:nth-child(3) a i[class="fas fa-trash icon"]'
        end
      end

      should 'remove' do
        page.find('a[data-target="#add_variables_modal"]').click
        fill_in 'variable_name', with: 'Student name'
        fill_in 'variable_identifier', with: 'student-name'
        click_button('add_variable')

        within('#variables-table tbody:nth-child(2) tr:nth-child(1) td:nth-child(3)') do
          find('a:nth-child(2)').click
        end

        within('table#variables-table tbody') do
          assert_no_selector 'tr:nth-child(1) td:nth-child(1)', text: 'Student name'
          assert_no_selector 'tr:nth-child(1) td:nth-child(2)', text: 'student-name'
          assert_no_selector 'tr:nth-child(1) td:nth-child(3) a i[class="fas fa-trash icon"]'
        end

        submit_form

        @document = create(:document, :certification, department: @department)
        visit edit_users_document_path(@document)
        within('table#variables-table tbody') do
          assert_no_selector 'tr:nth-child(1) td:nth-child(1)', text: 'Student name'
          assert_no_selector 'tr:nth-child(1) td:nth-child(2)', text: 'student-name'
          assert_no_selector 'tr:nth-child(1) td:nth-child(3) a i[class="fas fa-trash icon"]'
        end
      end

      should 'add to certification/declaration to front text' do
        page.find('a[data-target="#add_variables_modal"]').click
        fill_in 'variable_name', with: 'Student name'
        fill_in 'variable_identifier', with: 'student-name'
        click_button('add_variable')

        find('.document_front_text > div:nth-child(3) > div:nth-child(3) > div:nth-child(3)').click

        within('table#variables-table tbody') do
          find('a[data-variable-to-add="student-name"]').click
        end

        within('div.document_front_text') do
          assert_text('{student-name}')
        end
      end
    end

    context 'validations' do
      setup do
        page.find('a[data-target="#add_variables_modal"]').click
      end

      should 'both empty' do
        click_button('add_variable')

        within('div#add_variables_modal') do
          assert_selector 'div.variable_name div.invalid-feedback', text: I18n.t('errors.messages.blank')
          assert_selector 'div.variable_identifier div.invalid-feedback', text: I18n.t('errors.messages.blank')
        end
      end

      should 'indetifier empty' do
        fill_in 'variable_name', with: 'Student name'
        click_button('add_variable')

        within('div#add_variables_modal') do
          assert_no_selector 'div.variable_name div.invalid-feedback'
          assert_selector 'div.variable_identifier div.invalid-feedback', text: I18n.t('errors.messages.blank')
        end
      end

      should 'name empty' do
        fill_in 'variable_identifier', with: 'student-name'
        click_button('add_variable')

        within('div#add_variables_modal') do
          assert_selector 'div.variable_name div.invalid-feedback', text: I18n.t('errors.messages.blank')
          assert_no_selector 'div.variable_identifier div.invalid-feedback'
        end
      end

      should 'invalid indentifier' do
        fill_in 'variable_identifier', with: 'student name'
        click_button('add_variable')

        within('div#add_variables_modal') do
          assert_selector 'div.variable_identifier div.invalid-feedback', text: 'possui caracteres inválidos'
        end
      end

      should 'not duplicate variables with same identifier' do
        document = create(:document, :certification, department: @department)
        document.variables = [{ name: 'Student name', identifier: 'student-name' }]
        document.save
        visit edit_users_document_path(document)

        page.find('a[data-target="#add_variables_modal"]').click
        fill_in 'variable_identifier', with: 'student-name'
        click_button('add_variable')

        within('div#add_variables_modal') do
          assert_selector 'div.variable_identifier div.invalid-feedback', text: I18n.t('errors.messages.taken')
        end
      end

      should 'not duplicate indentifier with default_variables' do
        fill_in 'variable_name', with: 'Student'
        fill_in 'variable_identifier', with: 'name'
        click_button('add_variable')

        within('div#add_variables_modal') do
          assert_selector 'div.variable_identifier div.invalid-feedback'
        end
      end
    end

    context 'default_variables' do
      should 'be listed' do
        within('table#default-variables-table tbody') do
          Document.new.default_variables.each_with_index do |variable, index|
            assert_selector "tr:nth-child(#{index + 1}) td:nth-child(1)", text: variable[:name]
            assert_selector "tr:nth-child(#{index + 1}) td:nth-child(2)", text: variable[:identifier]
            assert_selector "tr:nth-child(#{index + 1}) td:nth-child(3) a i[class=\"fas fa-plus icon\"]"
          end
        end
      end

      should 'add to certification/declaration to front text' do
        document = create(:document, :certification, department: @department)
        visit edit_users_document_path(document)

        find('.document_front_text > div:nth-child(3) > div:nth-child(3) > div:nth-child(3)').click

        within('table#default-variables-table tbody') do
          find('a[data-variable-to-add="name"]').click
          find('a[data-variable-to-add="email"]').click
        end

        within('div.document_front_text') do
          assert_text('{name}')
          assert_text('{email}')
        end
      end

      should 'add to certification/declaration to back text' do
        document = create(:document, :certification, department: @department)
        visit edit_users_document_path(document)

        find('.document_back_text > div:nth-child(3) > div:nth-child(3) > div:nth-child(3)').click

        within('table#default-variables-table tbody') do
          find('a[data-variable-to-add="name"]').click
          find('a[data-variable-to-add="email"]').click
        end

        within('div.document_back_text') do
          assert_text('{name}')
          assert_text('{email}')
        end
      end
    end
  end
end
