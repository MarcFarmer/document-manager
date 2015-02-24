class Notifier < ActionMailer::Base
  default from: 'Document Manager'

  def org_invite(email,org,inviter)
    @org = org
    @inviter = inviter
    mail(to: email, subject: 'You have been invited to an organisation')
  end

  def assign_role(email,doc_name,creator,role)
    @doc_name = doc_name
    @creator = creator
    @role = role
    mail(to: email, subject: 'You have been assigned a role')
  end

  def doc_status(email,doc_name,outcome)
    @doc_name = doc_name
    @outcome = outcome
    mail(to: email, subject: 'Your document has been updated')
  end

end
