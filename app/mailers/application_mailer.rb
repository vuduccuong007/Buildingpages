class ApplicationMailer < ActionMailer::Base
  default from: -> { ENV.fetch("MAILER_FROM", "building-pages@example.test") }
  layout "mailer"
end
