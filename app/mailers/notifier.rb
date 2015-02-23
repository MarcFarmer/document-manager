class Notifier < ApplicationMailer

  def welcome_email(resource)
    @resource = resource
    @url  = 'localhost:3000'
    mail(to: 'andrewnguyen.x@gmail.com', subject: 'Welcome to Document Manager')
  end

end
