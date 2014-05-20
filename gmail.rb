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

  def mailbox(emails, n)
    num = n
    emails.each do |mail|
      puts "#{num.to_s.ljust(2)}. #{mail[:subject]}"
      num += 1
    end

    next_action = HighLine.ask("> or q: ")
    @controller.mailbox(n, next_action)
  end
end

class Controller
  attr_accessor :gm

  def initialize
    @views = Views.new(self)
    @gm = GmailModel.new
  end

  def mailbox(n = 0, action = nil)
    if action.nil?
      emails = @gm.latest_emails(20, n)
      emails.map! {|email| {subject: email.subject}}
      @views.mailbox(emails, n)
    elsif action == 'q'
      exit
    elsif action == '>'
      mailbox(n + 20)
    end
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

  def latest_emails(num, skip = 0)
    @gmail.inbox.emails(:all).reverse[skip..(skip+num)]
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
