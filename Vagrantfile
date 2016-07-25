# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'securerandom'
domain          = "-d CHANGEME.EDU"
db_ip           = "10.10.40.102"
db_ip_arg       = "-di #{db_ip}"
db_hostname     = "-dh dspace-5-db"
db_name         = "-dn dspace"
db_user         = "-du dspace"
db_pass         = "-dp #{SecureRandom.base64(33).gsub(/[\/\:]/,'')}"
app_ip          = "10.10.40.101"
app_ip_arg      = "-ai #{app_ip}"
app_hostname    = "-ah dspace-5-dev"
app_user        = "-au dspace"
tomcat_admin    = "-ta CHANGEME"
tomcat_password = "-tp CHANGEME"


# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|

  config.vm.define "db" do |db|
    db.vm.box = "centos/7"

    db.vm.network "forwarded_port", guest: 5432, host: 15432
    db.vm.network "private_network", ip: db_ip

    db.vm.provider "virtualbox" do |vb|
      vb.name = "dspace_5_db"
    end

    # part 1 - install
      db_pre_args = [db_hostname, domain, db_ip_arg].join(" ")
      db.vm.provision "db prerequisites", type: "shell", path: "script/db_prereqs.sh", args: db_pre_args

      db.vm.provision "db firewall", type: "shell", path: "script/db_firewall.sh"

      db_install_args = [db_name, db_user].join(" ")
      db.vm.provision "db install", type: "shell", path: "script/db_install.sh", args: db_install_args

      db_create_args = [db_name, db_user, db_pass].join(" ")
      db.vm.provision "db create", type: "shell", path: "script/db_create.sh", args: db_create_args

    # part 2 - update
    # NOTE: part 1 (db and app) must be complete before running part 2
    # NOTE: be sure to turn off the app (sudo systemctl stop tomcat) before restoring the database
    # TODO: segment this in a less confusing way
      # db.vm.provision "file", source: "db_backup/anon_dump.sql", destination: "db_backup/anon_dump.sql"
      # db.vm.provision "db restore", type: "shell", path: "script/db_restore.sh"
  end

  config.vm.define "app", primary: true do |app|
    app.vm.box = "centos/7"

    app.vm.network "forwarded_port", guest: 8080, host: 18080
    app.vm.network "private_network", ip: app_ip

    app.vm.provider "virtualbox" do |vb|
      vb.name = "dspace_5_dev"
    end

    # part 1 - install &/or deploy
      # do minimal provisioning to set up
      app_pre_args = [app_user, tomcat_admin, tomcat_password, app_hostname, domain, app_ip_arg].join(" ")
      app.vm.provision "prerequisites", type: "shell", path: "script/prereqs.sh", args: app_pre_args

      # configure firewall
      app.vm.provision "app firewall", type: "shell", path: "script/app_firewall.sh"

      # install prerequisites for the Mirage2 xmlui theme
      app_mirage_pre_args = [app_user].join(" ")
      app.vm.provision "mirage2 prerequisites", type: "shell", path: "script/prereqs_mirage2.sh", args: app_mirage_pre_args

      # -- EITHER --

        # # install database (if not using external db server)
        # db_hostname = "-dh localhost" # this will be needful when configuring dspace below
        # db_install_args = [db_name, db_user].join(" ")
        # app.vm.provision "db install", type: "shell", path: "script/db_install.sh", args: db_install_args
        # db_create_args = [db_name, db_user, db_pass].join(" ")
        # app.vm.provision "db create", type: "shell", path: "script/db_create.sh", args: db_create_args

      # --- OR ---

          # install and configure database client for external db server
          db_client_args = [db_ip_arg, db_hostname, domain, db_name, db_user, db_pass, app_user].join(" ")
          app.vm.provision "db client", type: "shell", path: "script/db_client.sh", args: db_client_args

      # install dspace
      app_build_args = [app_user, db_hostname, domain, db_name, db_user, db_pass].join(" ")
      app.vm.provision "build dspace", type: "shell", path: "script/build_dspace.sh", args: app_build_args

      # apache
      app_apache_args = [app_hostname, domain].join(" ")
      app.vm.provision "apache", type: "shell", path: "script/app_apache.sh", args: app_apache_args

    # part 2 - update
    # NOTE: part 1 (db and app) must be complete before running part 2
    # NOTE: be sure to turn off the app (sudo systemctl stop tomcat) before restoring the database
    # TODO: segment this in a less confusing way
      # app.vm.provision "db upgrade", type: "shell", path: "script/db_upgrade.sh"

  end

end
