namespace :db do
  desc "Populate the user database from Passport"
  task :refresh_users => :environment do
    puts "\n"

    response_body = User.access_token.get("/api/search/user_index/list.json?limit=9000&f[1]=roles:122562209").body
    users_to_add  = JSON.parse(response_body)['results']
    created_count = 0
    updated_count = 0

    users_to_add.each do |user_object|
      cleaned_data = User::clean_data user_object
      old_user = User.find_by_id(cleaned_data['id'])

      if old_user.blank?
        created_count+=1
        user = User.new cleaned_data
        user.save(:validate => false)
      else
        keys = cleaned_data.keys
        if old_user.slice(*keys) != cleaned_data
          updated_count+=1
          old_user.update cleaned_data
          puts "Updated #{cleaned_data['name']}"
        end
      end
    end

    puts "\n\n"
    puts "-----------------------------------"
    puts "Updated #{updated_count} users"
    puts "Created #{created_count} new users"
  end


  desc "assign default admins"
  task :assign_admins => :environment do
    default_admins = {
      2322 => "Joe Longstreet",
      1402 => "Michal Hontz",
      1781 => "Doug Koenig",
      1340 => "Kristi Veitch"
    }

    default_admins.each do |key, value|
      new_admin = User.find(key)
      new_admin.is_admin = true
      puts "Assigned #{value} as an admin"
      new_admin.save()
    end
  end


  desc "Populate the database with a series of nominations"
  task :stub_nominations => :environment do
    Nomination.delete_all

    # Create used nominations
    350.times do
      nomination  = create_nomination
      status      = 2
      entered_on  = random_date Time.local(2012, 1, 1), Time.local(2013, 12, 30)
      is_weekly_winner  = false
      is_monthly_winner = false

      if rand(10) < 3 then is_weekly_winner = true end
      if rand(20) < 2 then is_monthly_winner = true end

      nomination.update_columns(
        :status             => status,
        :entered_on         => entered_on,
        :is_weekly_winner   => is_weekly_winner,
        :is_monthly_winner  => is_monthly_winner
      )
    end

    # Create pending nominations
    15.times do
      nomination = create_nomination
      nomination.status = 1
      nomination.save()
    end

    # Create new nominations
    15.times do
      create_nomination
    end

    puts "Created #{Nomination.all.length} stubbed nominations"
  end

  desc "Create one nomination"
  task :stub_nomination => :environment do
    nomination = create_nomination
    nomination.save()
  end

  desc "Load some arbitrary file"
  task :load_file, [:file_path] => :environment do |t, args|
    file = File.read args[:file_path]
    ActiveRecord::Base.transaction do
      ActiveRecord::Base.connection.execute(file)
    end
  end

  def create_nomination
    Nomination.create(
      "description"    => Populator.words(15..40),
      "nominator_id"   => User.offset(rand(User.count)).first.id,
      "nominee_id"     => User.offset(rand(User.count)).first.id,
      "supervisor_id"  => User.offset(rand(User.count)).first.id
    )
  end

  def random_date from = 0.0, to = Time.now
    Time.at(from + rand * (to.to_f - from.to_f))
  end
end