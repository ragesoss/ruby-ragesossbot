require_relative 'labs_database'

class ProcessNewUsers
  def initialize(count: 2)
    @count = count
    @database = LabsDatabase.new
  end

  def import_users
    users = @database.new_users_with_edits
  end
end
