require 'application_system_test_case'

class DepartmentsTest < ApplicationSystemTestCase
  context 'users department' do
    setup do
      user = create(:user, :manager)
      @user2 = create(:user, :manager)
      login_as(user, as: :user)
      @department_user = create(:department_user, :responsible)
      sign_in @department_user.user
    end

    should 'display list department members page and verify data' do
      @department_user.department.add_member(user_id: @user2.id, role: 'collaborator')

      visit users_department_members_path(@department_user.department.id)

      assert_selector 'h1.page-title', text: "Membros do departamento #{@department_user.department.name}"

      within('table.table tbody') do
        @department_user.department.department_users.each_with_index do |department_user, index|
          user = department_user.user
          child = index + 1
          base_selector = "tr:nth-child(#{child})"

          assert_selector base_selector, text: user.name
          assert_selector base_selector, text: user.email
          assert_selector base_selector, text: I18n.t("views.status.#{user.active?}")
          if I18n.t('enums.roles.responsible') == user.role
            # para o primeiro usuário criado que vem o role nil
            assert_selector base_selector, text: I18n.t('enums.roles.responsible')
          end
          if I18n.t("enums.roles.#{user.role}") == user.role
            # para o segundo usuário criado que vem o role passada no parametro da criação
            assert_selector base_selector, text: I18n.t("enums.roles.#{user.role}")
          end
          # assert_selector base_selector, text: I18n.t('enums.roles.responsible')
          # assert_selector base_selector, text: I18n.t("enums.roles.#{user.role}")
          assert_selector "#{base_selector}
                           a[href='#{users_department_remove_member_path(@department_user.department.id,
                                                                         user.id)}'][data-method='delete']"
        end
      end
    end

    should 'successfully add member' do
      visit users_department_members_path(@department_user.department.id)

      fill_in 'department_user_user', with: @user2.name
      find("#department_user_user-dropdown .dropdown-item[data-value='#{@user2.id}']").click

      submit_form("button[type='submit']")

      assert_current_path users_department_members_path(@department_user.department.id)

      assert_includes @department_user.department.department_users.map(&:user_id), @user2.id
    end

    should 'unsuccessfully add member' do
      visit users_department_members_path(@department_user.department.id)

      submit_form("button[type='submit']")

      assert_current_path users_department_members_path(@department_user.department.id)

      assert_selector('div.alert.alert-warning', text: I18n.t('flash.actions.add.errors.not'))
    end

    should 'remove a member' do
      visit users_department_members_path(@department_user.department.id)

      fill_in 'department_user_user', with: @user2.name
      find("#department_user_user-dropdown .dropdown-item[data-value='#{@user2.id}']").click

      submit_form("button[type='submit']")

      assert_current_path users_department_members_path(@department_user.department.id)

      assert_includes @department_user.department.department_users.map(&:user_id), @user2.id
      within('table.table tbody') do
        accept_confirm do
          find("a[href='#{users_department_remove_member_path(@department_user.department.id,
                                                              @user2.id)}'][data-method='delete']").click
        end
      end

      assert_current_path users_department_members_path(@department_user.department.id)

      assert_selector('div.alert.alert-success',
                      text: I18n.t('flash.actions.remove.m', resource_name: User.model_name.human))

      within('table.table tbody') do
        refute_text @user2.name
        refute_selector "a[href='#{users_department_remove_member_path(@department_user.department.id,
                                                                       @user2.id)}'][data-method='delete']"
      end
    end
  end
end
