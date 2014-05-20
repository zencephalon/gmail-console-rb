require 'highline/import'
require 'gmail'

module Views
  def self.login
    username = HighLine.ask("Username: ")
    password = HighLine.ask("Password: ") { |q| q.echo = '*' }
    Controller.authenticate(username, password)
  end
end

class Controller

  def home
    Views.login
  end

  def authenticate(username, password)
    @gm = GmailModel.new(username, password)
  end
end

class GmailModel
  def initialize(username, password)
    @gmail = Gmail.new(username, password)
  end
end

controller = Controller.new
controller.home
