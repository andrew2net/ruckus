class BaseMailer < ActionMailer::Base
  layout 'mailer'
  default from: "info@#{Figaro.env.domain}"
  helper TextHelper
end
