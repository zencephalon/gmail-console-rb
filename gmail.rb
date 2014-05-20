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

  def mailbox(emails)
    num = 1
    emails.each do |mail|
      puts "#{num.to_s.ljust(2)}. #{mail[:subject]}"
      num += 1
    end
  end
end

class Controller
  attr_accessor :gm

  def initialize
    @views = Views.new(self)
    @gm = GmailModel.new
  end

  def mailbox
    emails = @gm.latest_emails(20)
    emails.map! {|email| {subject: email.subject}}
    @views.mailbox(emails)
  end

  def login
    @views.login
  end

  def home
    if @gm.logged_in?
      mailbox
    else
      login
    end
  end

  def authenticate(username, password)
    @gm.authenticate(username, password)
    home
  end
end

class GmailModel
  def initialize
    @gmail = nil
  end

  def authenticate(username, password)
    @gmail = Gmail.new(username, password)
    @gmail.login
  end

  def latest_emails(num)
    @gmail.inbox.emails(:all).reverse.take(10)
  end

  def logged_in?
    if @gmail.nil?
      return false
    else
      return @gmail.logged_in?
    end
  end
end

controller = Controller.new
p controller.gm
controller.home
