$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rubygems'
require 'rspec'
require 'mocha/api'
require 'yaml'
require 'gmail'

require_relative 'support/labels_helpers'
require_relative 'support/mailbox_helpers'

RSpec.configure do |config| 
  config.mock_with :mocha
end

def within_gmail(&block)
  gmail = Gmail.connect!(*TEST_ACCOUNT["plain"])
  yield(gmail)
  gmail.logout if gmail
end

def mock_mailbox(box = "INBOX", read_only = false, &block)
  within_gmail do |gmail|
    mailbox = Gmail::Mailbox.new(gmail, box, read_only)
    yield(mailbox) if block_given?
    mailbox
  end
end

# Run test by creating your own test account with credentials in account.yml
TEST_ACCOUNT =
  begin
    YAML.load_file(File.join(File.dirname(__FILE__), 'account.yml'))
  rescue Exception => ex
    puts "Couldn't create a test account: #{ex.message}"
  end
