require 'rvm/capistrano' # Для работы rvm
require 'bundler/capistrano' # Для работы bundler. 
# При изменении гемов bundler автоматически обновит все гемы на сервере, чтобы они в точности соответствовали гемам разработчика. 

set :application, "anifag"
set :rails_env, "production"
set :domain, "user@host"
set :deploy_to, "/var/www/#{application}"
ssh_options[:keys] = ["/where/ever/it/is/key.pem"]
set :use_sudo, false
set :unicorn_conf, "#{deploy_to}/current/config/unicorn.rb"
set :unicorn_pid, "#{deploy_to}/shared/pids/unicorn.pid"

set :rvm_ruby_string, 'ruby-1.9.3-p194' # Это указание на то, какой Ruby интерпретатор мы будем использовать.

set :repository,  "git://github.com/Arimeka/new_anifag.git" 

set :scm, :git # Используем git.
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

set :branch, "master"
set :deploy_via, :remote_cache

role :web, domain
role :app, domain
role :db,  domain, :primary => true

before 'deploy:setup', 'rvm:install_rvm', 'rvm:install_ruby'

after 'deploy:update_code', :roles => :app do
  # Здесь для примера вставлен только один конфиг с приватными данными - database.yml. 
  # Обычно для таких вещей создают папку /srv/myapp/shared/config и кладут файлы туда. 
  # При каждом деплое создаются ссылки на них в нужные места приложения.
  run "rm -f #{current_release}/config/database.yml"
  run "ln -s #{deploy_to}/shared/config/database.yml #{current_release}/config/database.yml"

  run "rm -f #{current_release}/config/initializers/setup_mailer.rb"
  run "ln -s #{deploy_to}/shared/config/initializers/setup_mailer.rb #{current_release}/config/initializers/setup_mailer.rb"
end

namespace :deploy do
  task :restart do
    run "if [ -f #{unicorn_pid} ] && [ -e /proc/$(cat #{unicorn_pid}) ]; then kill -USR2 `cat #{unicorn_pid}`; else cd #{deploy_to}/current && bundle exec unicorn_rails -c #{unicorn_conf} -E #{rails_env} -D; fi"
  end
  task :start do
    run "bundle exec unicorn -c #{unicorn_conf} -E #{rails_env} -D"
  end
  task :stop do
    run "if [ -f #{unicorn_pid} ] && [ -e /proc/$(cat #{unicorn_pid}) ]; then kill -QUIT `cat #{unicorn_pid}`; fi"
  end
end

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end