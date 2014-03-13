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
end
