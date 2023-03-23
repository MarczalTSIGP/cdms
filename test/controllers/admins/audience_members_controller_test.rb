require 'test_helper'

class Admins::AudienceMembersControllerTest < ActionDispatch::IntegrationTest
  context 'autenticated' do
    setup do
      @audience_member = create(:audience_member)
      sign_in create(:user, :manager)
    end

    context '200' do
      # teardown do
      #   assert_active_link(href: admins_audience_members_path)
      # end

      should 'get new' do
        get new_admins_audience_member_path

        assert_response :success
      end

      context '#create' do
        should 'successfully' do
          assert_difference('AudienceMember.count', 1) do
            post admins_audience_members_path, params: { audience_member: attributes_for(:audience_member) }
          end
          assert_redirected_to admins_audience_members_path
          assert_equal I18n.t('flash.actions.create.m', resource_name: AudienceMember.model_name.human),
                       flash[:success]
          follow_redirect!
        end

        should 'unsuccessfully' do
          assert_no_difference('AudienceMember.count') do
            post admins_audience_members_path, params: { audience_member: attributes_for(:audience_member, name: '') }
          end

          assert_response :success
          assert_equal I18n.t('flash.actions.errors'), flash[:error]
        end
      end

      context '#update' do
        should 'successfully' do
          patch admins_audience_member_path(@audience_member), params: { audience_member: { name: 'updated' } }

          assert_redirected_to admins_audience_members_path
          assert_equal I18n.t('flash.actions.update.m', resource_name: AudienceMember.model_name.human),
                       flash[:success]
          @audience_member.reload

          assert_equal 'updated', @audience_member.name
          follow_redirect!
        end

        should 'unsuccessfully' do
          patch admins_audience_member_path(@audience_member), params: { audience_member: { name: '' } }

          assert_response :success
          assert_equal I18n.t('flash.actions.errors'), flash[:error]

          name = @audience_member.name
          @audience_member.reload

          assert_equal name, @audience_member.name
        end
      end
    end

    should 'redirect to index' do
      id = (AudienceMember.last&.id || 0) + 1

      requests = {
        get: [edit_admins_audience_member_path(id), admins_audience_member_path(id)],
        patch: [admins_audience_member_path(id)],
        delete: [admins_audience_member_path(id)]
      }

      requests.each do |method, routes|
        routes.each do |route|
          send(method, route)

          assert_redirected_to admins_audience_members_path
          assert_equal I18n.t('flash.not_found'), flash[:error]
        end
      end
    end
  end

  context 'unauthenticated' do
    should 'redirect to login when not authenticated' do
      assert_redirect_to(new_user_session_path)
    end

    should 'redirect to login when logged as non administrator user' do
      sign_in create(:user)

      assert_redirect_to(users_root_path)
    end
  end

  private

  def assert_redirect_to(redirect_to)
    requests.each do |method, routes|
      routes.each do |route|
        send(method, route)

        assert_redirected_to redirect_to
      end
    end
  end

  def requests
    {
      get: [admins_audience_members_path, new_admins_audience_member_path,
            edit_admins_audience_member_path(1), admins_audience_member_path(1)],
      post: [admins_audience_members_path],
      patch: [admins_audience_member_path(1)],
      delete: [admins_audience_member_path(1)]
    }
  end
end
