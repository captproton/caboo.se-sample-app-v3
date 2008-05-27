set :application, "opensalestax"
set :repository, "svn://your.repository"

  role :web, "web.com"
  role :app, "app.web.com"
  role :db,  "db.web.com", :primary => true

  set :deploy_to, "/var/rails/#{application}/"
  set :user, `whoami`.strip

desc "Backup the DB and download it"
task :backup, :roles => :db, :only => { :primary => true } do
  filename = "/tmp/#{application}.dump.#{Time.now.to_f}.sql.bz2"
  text = capture "cat #{deploy_to}/#{shared_dir}/system/database.yml"
  yaml = YAML::load(text)

  on_rollback { delete filename }
  run "mysqldump -u #{yaml['production']['username']} -p #{yaml['production']['database']} | bzip2 -c > #{filename}" do |ch, stream, out|
    ch.send_data "#{yaml['production']['password']}\n" if out =~ /^Enter password:/
  end
  `mkdir -p #{File.dirname(__FILE__)}/../backups`
  `rsync #{user}@#{roles[:db][0].host}:#{filename} #{File.dirname(__FILE__)}/../backups/`
  delete filename
end

desc "Start the mongrels"
task :spinner, :roles => :app do
  run "cd #{current_path} && mongrel_rails cluster::start"
end

desc "Restart mongrel"
task :restart, :roles => :app do
  run "cd #{current_path} && mongrel_rails cluster::restart"
end
