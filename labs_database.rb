require 'mysql2'
require 'yaml'

class LabsDatabase
  def initialize
    config = YAML.load File.read('database.yml')
    @client = Mysql2::Client.new(config)
  end

  def new_users_with_edits(max_edit_count: 5)
    @client.query("
      SELECT * FROM user
      WHERE user_editcount < #{max_edit_count}
      ORDER BY user_id DESC
      LIMIT 100
    ")
  end
end
