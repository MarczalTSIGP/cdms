require 'test_helper'

class Users::DepartmentsControllerTest < ActionDispatch::IntegrationTest
  context 'authenticated with responsible user' do
    setup do
      @department_user = create(:department_user, :responsible)
      sign_in @department_user.user
    end

    should 'get members' do
      get users_department_members_path(@department_user.department)

      assert_response :success
    end

    should 'add member' do
      new_user = create(:user)
      assert_difference('@department_user.department.users.count', 1) do
        post users_department_add_member_path(@department_user.department),
             params: { department_user: { user_id: new_user.id,
                                          department_id: @department_user.department.id,
                                          role: :collaborator } }
      end
      assert_redirected_to users_department_members_path(@department_user.department)
    end

    should 'not add a responsible member' do
      new_user = create(:user)
      post users_department_add_member_path(@department_user.department),
           params: { department_user: { user_id: new_user.id,
                                        department_id: @department_user.department.id,
                                        role: :responsible } }

      assert_equal :collaborator, DepartmentUser.last.role.to_sym
    end

    context 'remove' do
      should 'member' do
        new_user = create(:user)
        assert_difference('@department_user.department.users.count', 0) do
          post users_department_add_member_path(@department_user.department),
               params: { department_user: { user_id: new_user.id,
                                            department_id: @department_user.department.id,
                                            role: :collaborator } }

          delete users_department_remove_member_path(@department_user.department, new_user)
        end
      end

      should 'not remove itself' do
        assert_no_difference('DepartmentUser.count') do
          delete users_department_remove_member_path(@department_user.department, @department_user.user)
        end
      end
    end
  end

  context 'no privileges' do
    setup do
      @user = create(:user)
      @department = create(:department)
    end

    should 'redirect when unauthenticated' do
      assert_redirect_to(unauthenticated_requests, new_user_session_path)
    end

    should 'redirect with no departments' do
      sign_in @user

      assert_redirect_to(non_responsible_requests(@department), users_show_department_path(@department))
    end

    should 'redirect when is collaborator of department' do
      sign_in @user
      @department.department_users.create(user: @user, role: :collaborator)

      assert_redirect_to(non_responsible_requests(@department), users_show_department_path(@department))
    end
  end

  private

  def unauthenticated_requests
    {
      get: [users_department_members_path(1)],
      post: [users_department_add_member_path(1)],
      delete: [users_department_remove_member_path(1, 1)]
    }
  end

  def non_responsible_requests(department)
    flash = { type: :warning, message: I18n.t('flash.actions.responsible.non') }
    {
      get: [{ route: users_department_members_path(department), flash: flash }],
      post: [{ route: users_department_add_member_path(department), flash: flash }],
      delete: [{ route: users_department_remove_member_path(department, 1), flash: flash }]
    }
  end
end
