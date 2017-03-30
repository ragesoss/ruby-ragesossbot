require 'active_record'
require 'sqlite3'
require 'logger'

ActiveRecord::Base.logger = Logger.new('debug.log')
ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: 'ragesossbot.sqlite3'
)

class User < ActiveRecord::Base
end
