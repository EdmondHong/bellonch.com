# Configuration
set :application, "bellonch.com"
set :keep_releases, 5

# Stages
set :stages, %w{ production }
set :default_stage, "production"

# SCM
set :scm, :git
set :deploy_via, :remote_cache
set :repository, "git@github.com:albertbellonch/bellonch.com.git"
set :ssh_options, { port: 8622, forward_agent: true }

# Server
server "bellonch.com", :app
set :deploy_to, "/var/www/html/bellonch.com"

# Users
set :use_sudo, false
set :user, "deployer"

# Others
set :copy_exclude, %w{ .gitignore README.md }

# Custom recipes
namespace :wordpress do
    desc "Setup symlinks for a WordPress project"
    task :create_symlinks, roles: :app do
        run "ln -nfs #{shared_path}/uploads #{release_path}/wp-content/uploads"
        run "ln -nfs #{shared_path}/cache #{release_path}/wp-content/cache"
        run "ln -nfs #{shared_path}/wp-config-production.php #{release_path}/wp-config-production.php"
    end

    desc "Checkout original files" # TODO solve it for real
    task :checkout_original_files, roles: :app do
        %w{
          .gitignore
          wp-content/themes/twentyfifteen/genericons/README.md
          wp-content/themes/wordpress-bootstrap/README.md
          wp-content/themes/wordpress-bootstrap/bower_components/bootstrap/README.md
          wp-content/themes/wordpress-bootstrap/bower_components/font-awesome/.gitignore
          wp-content/themes/wordpress-bootstrap/bower_components/modernizer/.gitignore
        }.each do |filename|
          run "cd #{release_path}; git checkout #{filename}"
        end
    end
end

after "deploy:create_symlink", "wordpress:create_symlinks"
after "deploy:create_symlink", "wordpress:checkout_original_files"
