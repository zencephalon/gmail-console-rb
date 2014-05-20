require 'highline/import'
require 'gmail'

class Views
  def initialize(controller)
    @controller = controller
  end

  def login
    username = HighLine.ask("Username: ")
    password = HighLine.ask("Password: ") { |q| q.echo = '*' }
    @controller.authenticate(username, password)
  end
end

class Controller
  def initialize
    @views = Views.new(self)
  end

  def home
    @views.login
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
