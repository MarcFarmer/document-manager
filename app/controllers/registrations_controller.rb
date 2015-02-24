class RegistrationsController < Devise::RegistrationsController

  def create
    puts '@!#@$%#%$#^@Q$#@^$#ANDREW NGUYEN !@#@!$#@$%^#$&%^$@#@'
    super

    Notifier.welcome_email('a1627698@student.adelaide.edu.au').deliver_now

  end
end