require 'application_system_test_case'

class DepartmentsTest < ApplicationSystemTestCase
  context 'create' do
    setup do
      user = create(:user, :manager)
      user2 = create(:user, :manager)
      login_as(user, as: :user)
      @department_user = create(:department_user, :responsible)
      sign_in @department_user.user
      puts 'PUTSZANDO ABAXO$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$'
      puts @department_user.user.id, @department_user.department.id
      puts 'PUTSZANDO create finalizado'
      #@department_user.department.add_member(user_id: user2.id, role: 'responsible')
    end
  
  should 'access department members page and verify data' do
    visit users_department_members_path(@department_user.department.id)

    # Verificar título da página
    puts 'PUTZANDO ABAIXO'
    puts @department_user.department.name, "putss acimaaaaaaaaaaaaaaaaaaaa"
    assert_selector 'h1.page-title', text: "Membros do departamento #{@department_user.department.name}"

    within('table.table tbody') do
        #@department_user.user.each_with_index do |user, index|
        @department_user.department.department_users.each_with_index do |department_user, index|
            user = department_user.user
            puts user.name, user.email, user.active?, "user.role...: #{user.role.to_s}" 
            child = index + 1
            #base_selector = "table tbody tr:nth-child(#{child})"
            base_selector = "tr:nth-child(#{child})"
            assert_selector base_selector, text: user.name
            assert_selector base_selector, text: user.email
            assert_selector base_selector, text: I18n.t("views.status.#{user.active?}")
            assert_selector base_selector, text: I18n.t('enums.roles.responsible') # PARA O USER DEFAUL FUNCIONA DEMAIS NÃO 
            #assert_selector base_selector, text: I18n.t("enums.roles.#{user.role}")
            #assert_selector base_selector, text: user.role

            #AO VERIFICAR SOMENTE O USUARIO 1 NÃO GRAVA A ROLE DELE, AO ADICIONAR O 2 USUARIO COM A ROEL PASSADA COMO PARAMETRO ELE GRAVA
            # FAZER  O TESTE PARECIDO COM O DEPARTMENTS_TEXTS/MEMBERS_TEST.RB 
        end
    end
  end

end
end






    # Verificar se os dados do usuário estão presentes na tabela
    #assert_selector 'td', text: @department_user.user.name
    #assert_selector 'td', text: @department_user.user.email
    #assert_selector 'td', text: t("views.status.#{department_user.user.active?}")
    #assert_selector 'td', text: t("enums.roles.#{department_user.role}")

    # Verificar a presença do botão de remoção de membro
    #assert_selector 'a', text: 'Remove', count: 1

    # Clique no botão de remoção de membro e verifique o comportamento
    #click_link 'Remove'
    #page.driver.browser.switch_to.alert.accept

    # Verificar se o membro foi removido da tabela
    #assert_no_selector 'td', text: @department_user.user.name