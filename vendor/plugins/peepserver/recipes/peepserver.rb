
class Capistrano::Configuration

  ##
  # Print an informative message with asterisks.

  def inform(message)
    puts "#{'*' * (message.length + 4)}"
    puts "* #{message} *"
    puts "#{'*' * (message.length + 4)}"
  end

  ##
  # Read a file and evaluate it as an ERB template.
  # Path is relative to this file's directory.

  def render_erb_template(filename)
    template = File.read(filename)
    result   = ERB.new(template).result(binding)
  end

  ##
  # Run a command and return the result as a string.
  #
  # TODO May not work properly on multiple servers.

  def run_and_return(cmd)
    output = []
    run cmd do |ch, st, data|
      output << data
    end
    return output.to_s
  end

end


##
# Custom installation tasks for CentOS (RailsMachine).
#
# Author: Geoffrey Grosenbach http://topfunky.com
#         November 2007

namespace :peepcode do

  desc "Copy config files"
  task :copy_config_files do
    run "cp #{shared_path}/config/* #{release_path}/config/"
  end
  after "deploy:update_code", "peepcode:copy_config_files"


  desc "Create shared/config directory and default database.yml."
  task :create_shared_config do
    run "mkdir -p #{shared_path}/config"

    # Copy database.yml if it doesn't exist.
    result = run_and_return "ls #{shared_path}/config"
    unless result.match(/database\.yml/)
      contents = render_erb_template(File.dirname(__FILE__) + "/templates/database.yml")
      put contents, "#{shared_path}/config/database.yml"
      inform "Please edit database.yml in the shared directory."
    end
  end
  after "deploy:setup", "peepcode:create_shared_config"


  namespace :install do

    desc "Install server software"
    task :default do
      setup

      # TODO
      # * Uninstall httpd: chkconfig --del httpd

      ##git
      ##memcached
      ##munin
      ##httperf
      ##emacs
      ##tree
      special_gems
      set_time_to_utc
    end

    task :setup do
      sudo "rm -rf src"
      run  "mkdir -p src"
    end

    desc "Install git"
    task :git do
      curl
      cmd = [
        "cd src",
        "wget http://kernel.org/pub/software/scm/git/git-1.5.3.5.tar.gz",
        "tar xfz git-1.5.3.5.tar.gz",
        "cd git-1.5.3.5",
        "make prefix=/usr/local all",
        "sudo make prefix=/usr/local install"
      ].join(" && ")
      run cmd
    end

    desc "Install curl"
    task :curl do
      sudo "yum install curl curl-devel -y"
    end

    desc "Install memcached"
    task :memcached do
      # TODO Needs to run ldconfig after libevent is installed
      run "echo '/usr/local/lib' > ~/src/memcached-i386.conf"
      sudo "mv ~/src/memcached-i386.conf /etc/ld.so.conf.d/memcached-i386.conf"
      sudo "/sbin/ldconfig"

      result = File.read(File.dirname(__FILE__) + "/templates/install-memcached-linux.sh")
      put result, "src/install-memcached-linux.sh"

      cmd = [
        "cd src",
        "sudo sh install-memcached-linux.sh"
      ].join(" && ")
      run cmd
    end

    desc "Install emacs"
    task :emacs do
      sudo "yum install emacs -y"
    end

    desc "Install gems needed by PeepCode"
    task :special_gems do
      # TODO hpricot
      %w(libxml-ruby gruff sparklines ar_mailer bong production_log_analyzer rspec).each do |gemname|
        sudo "gem install #{gemname} -y"
      end
    end

    desc "Install munin"
    task :munin do
      sudo "rpm -Uhv http://apt.sw.be/packages/rpmforge-release/rpmforge-release-0.3.6-1.el4.rf.i386.rpm"
      sudo "yum install munin munin-node -y"
      post_munin
      munin_plugins
    end

    desc "Post-Munin Tasks"
    task :post_munin do
      cmds = [
        "rm -rf /var/www/munin",
        "mkdir -p /var/www/html/munin",
        "chown munin:munin /var/www/html/munin",
        "/sbin/service munin-node restart"
      ]
      cmds.each do |cmd|
        sudo cmd
      end

      inform "You must link /var/www/html/munin to a web-accessible location."
    end

    desc "Upload and configure desired plugins for munin."
    task :munin_plugins do
      # Reset
      sudo "rm -f /etc/munin/plugins/*"

      # Upload
      put File.read(File.dirname(__FILE__) + "/templates/memcached_"), "/tmp/memcached_"
      sudo "cp /tmp/memcached_ /usr/share/munin/plugins/memcached_"
      sudo "chmod 755 /usr/share/munin/plugins/memcached_"

      # Configure
      {
        "cpu" => "cpu",
        "df" => "df",
        "fw_packets" => "fw_packets",
        "if_eth0" => "if_",
        "if_eth1" => "if_",
        "load" => "load",
        "memory" => "memory",
        "mysql_bytes" => "mysql_bytes",
        "mysql_queries" => "mysql_queries",
        "mysql_slowqueries" => "mysql_slowqueries",
        "mysql_threads" => "mysql_threads",
        "netstat" => "netstat",
        "ping_nubyonrails.com" => "ping_",
        "ping_peepcode.com" => "ping_",
        "ping_staging.topfunky.railsmachina.com" => "ping_",
        "ping_rubyonrailsworkshops.com" => "ping_",
        "ping_theonlineceo.com" => "ping_",
        "ping_topfunky.com" => "ping_",
        "processes" => "processes",
        "swap" => "swap",
        "users" => "users",
      }.each do |name, source|
        sudo "ln -s /usr/share/munin/plugins/#{source} /etc/munin/plugins/#{name}"
      end
      sudo "/sbin/service munin-node restart"
      sudo "-u munin munin-cron"

      inform "You must may need to run: sudo cpan Cache::Memcached"
    end

    desc "Install command-line directory lister"
    task :tree do
      cmd = [
        "cd src",
        "wget ftp://mama.indstate.edu/linux/tree/tree-1.5.1.1.tgz",
        "tar xfz tree-1.5.1.1.tgz",
        "cd tree-1.5.1.1",
        "make",
        "sudo make install"
      ].join(' && ')
      run cmd
    end

    desc "Set time to UTC"
    task :set_time_to_utc do
      sudo "ln -nfs /usr/share/zoneinfo/UTC /etc/localtime"
    end

    desc "Install newer version of make"
    task :make do
      cmd = [
        "cd src",
        "wget http://ftp.gnu.org/pub/gnu/make/make-3.81.tar.gz",
        "tar xfz make-3.81.tar.gz",
        "cd make-3.81",
        "./configure --prefix=/usr/local",
        "make",
        "sudo make install"
      ].join(" && ")
      run cmd
    end


    desc "Install beanstalk in-memory queue"
    task :beanstalk do
      # TODO Bail unless make 3.81 is installed
      cmd = [
        "cd src",
        "git clone http://xph.us/src/beanstalkd.git",
        "cd beanstalkd",
        "/usr/local/bin/make"
      ].join(" && ")
      # TODO Install it somewhere
      run cmd
    end

  end

end
