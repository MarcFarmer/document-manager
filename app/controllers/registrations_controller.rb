class RegistrationsController < Devise::RegistrationsController

  def create
    puts '@!#@$%#%$#^@Q$#@^$#ANDREW NGUYEN !@#@!$#@$%^#$&%^$@#@'
    super

    Notifier.welcome_email(resource).deliver_now

  end
end