require 'active_record'
require 'sqlite3'
require 'logger'

# t.string :username
# t.datetime :registration
# t.string :condition
# t.boolean :invited, default: false

ActiveRecord::Base.logger = Logger.new('debug.log')
ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: 'ragesossbot.sqlite3',
  encoding: 'utf8'
)

class User < ActiveRecord::Base
  def talk_page
    "User_talk:#{username}"
  end
end
