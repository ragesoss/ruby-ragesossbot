require_relative 'labs_database'
require_relative 'user'
require_relative 'wiki_api'
require 'pp'

class ProcessNewUsers
  def initialize(count: 2)
    @count = count
    @database = LabsDatabase.new
    @wiki_api = WikiApi.new
  end

  def import_users(dry_run: true)
    user_rows = @database.new_users_with_edits(limit: @count)
    users = user_rows.map do |user_row|
      username = user_row['user_name'].force_encoding('UTF-8')
      next if User.exists?(username: username)
      User.new(
        username: username,
        registration: DateTime.parse(user_row['user_registration'])
      )
    end.compact
    # Make sure we have an even number
    users.pop unless users.length.even?

    # Divide into two random groups
    users.shuffle!
    users_in_two_groups = users.in_groups(2)
    @experimental_group = users_in_two_groups[0]
    @control_group = users_in_two_groups[1]

    pp 'EXPERIMENTAL GROUP'
    @experimental_group.each do |user|
      user.condition = 'experiment'
      if dry_run
        pp user.username
      else
        user.save
      end
    end

    pp 'CONTROL_GROUP'
    @control_group.each do |user|
      user.condition = 'control'
      if dry_run
        pp user.username
      else
        user.save
      end
    end

    add_talk_page_template_for_experimental_group
  end

  def add_talk_page_template_for_experimental_group
    @experimental_group.each do |user|
      add_template_to_talk_page(user.talk_page, dry_run: dry_run)
      pp "#{user.username} invited"
      user.update_attribute(:invited, true) unless dry_run
      sleep 1
    end
  end

  def add_template_to_talk_page(talk_page, dry_run: true)
    message = {
      sectiontitle: '{{subst:PAGENAME}}, welcome to Wikipedia!',
      text: '{{Welcome training modules|signed=~~~~}}',
      summary: 'invitation to try training modules'
    }
    @wiki_api.add_new_section(talk_page, message, dry_run: dry_run)
  end
end
