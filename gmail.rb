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
    clear_screen

    num = n
    emails.each do |mail|
      print_subject(mail[:subject], num)
      num += 1
    end

    get_next_action(n)
  end

  def email(mail, n)
    clear_screen

    print_subject(mail[:subject], n)
    puts mail[:body]

    get_next_action(n)
  end

  def clear_screen
    puts "\e[H\e[2J"
  end

  def print_subject(subject, n)
    puts "#{n.to_s.ljust(2)}. #{subject}"
  end

  def get_next_action(n)
    next_action = HighLine.ask("> or q or #: ")
    @controller.mailbox(n, next_action)
  end
end

class Controller
  attr_accessor :gm

  def initialize
    @views = Views.new(self)
    @gm = GmailModel.new
  end

  def email(n)
    email = @gm.get_email(n)
    email = {subject: email.subject, body: email.message.text_part.body}
    @views.email(email, n)
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
    else
      email(action.to_i)
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
    @emails = @gmail.inbox.emails(:all).reverse
  end

  def latest_emails(num, skip = 0)
    @emails[skip..(skip+num)]
  end

  def get_email(num)
    @emails[num]
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
controller.home
