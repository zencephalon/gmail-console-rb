require 'highline'
require 'gmail'

module Views
  def self.login
    username = ask("Username: ")
    password = ask("Password: ") { |q| q.echo = '*' }
    Controller.authenticate(username, password)
  end
end

class Controller
  def home
    Views.login
  end

  def authenticate(username, password)
    @gmail = GmailModel.new(username, password)
  end
end

class GmailModel
  def authenticate(user

  end

end

controller = Controller.new
controller.home
