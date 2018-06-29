module ControllersHelper
  extend ActiveSupport::Concern

  module ClassMethods
    def check_authorizing(&block)
      specify 'access should be denied' do
        sign_out :account
        instance_eval(&block)

        if request.xhr? || request.params[:format] == 'js'
          expect(response.status).to eq 401
        else
          expect(response).to redirect_to root_path(show_login_popup: true)
        end
      end
    end
  end

  def with_subdomain(subdomain)
    @request.host = "#{subdomain}.example.com"
  end

  def xhr(request_method, action, parameters = nil, session = nil, flash = nil)
    @request.env['HTTP_X_REQUESTED_WITH'] = 'XMLHttpRequest'
    @request.env['HTTP_ACCEPT'] ||=  [Mime::JS, Mime::HTML, Mime::XML, 'text/xml', Mime::ALL].join(', ')
    __send__(request_method, action, parameters, session, flash)
  end
end
