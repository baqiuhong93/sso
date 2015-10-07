namespace :access_grants  do
  desc "delete access_grants"
  task :delete => :environment do
    access_grants = AccessGrant.select("max(id) as id,user_id,client_id").group("user_id,client_id").having("count(*) > 1")
    access_grants.each do |a_g|
      AccessGrant.where("user_id=#{a_g.user_id} and client_id=#{a_g.client_id} and id < #{a_g.id}").destroy_all
    end
  end
end