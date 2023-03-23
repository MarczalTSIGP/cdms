module Asserts
  module RedirectTo
    def assert_redirect_to(requests, redirect_to)
      requests.each do |method, routes|
        routes.each do |route|
          if route.is_a?(Hash)
            assert_redirect_to_and_flash(method, route, redirect_to)
          else
            assert_only_redirect_to(method, route, redirect_to)
          end
        end
      end
    end

    private

    def assert_redirect_to_and_flash(method, route, redirect_to)
      assert_only_redirect_to(method, route[:route], redirect_to)
      assert_equal(route[:flash][:message], flash[route[:flash][:type]])
    end

    def assert_only_redirect_to(method, route, redirect_to)
      send(method, route)

      assert_redirected_to redirect_to, "should redirect_to #{route}"
    end
  end
end
