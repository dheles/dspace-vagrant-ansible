# -*- mode: ruby -*-
# vi: set ft=ruby :

require_relative './script/authorize_key'
require 'securerandom'

domain          = "jhu.dev"
auto_user       = "deploy"
auto_user_arg   = "-ou #{auto_user}"
auto_key        = "~/.ssh/dspace_stage.pub"


# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|

  config.vm.box = "centos/7"

  {
    # 'dspace_dev'      => '10.10.20.101',
    'dspace-db-dev'   => '10.10.20.102'
    # 'dspace_stage'    => '10.10.20.103',
    # 'dspace_db_stage' => '10.10.20.104',
    # 'dspace_prod'     => '10.10.20.105',
    # 'dspace_db_prod'  => '10.10.20.106'
  }.each do |short_name, ip|
    config.vm.define short_name do |host|
      host.vm.network 'private_network', ip: ip
      host.vm.hostname = "#{short_name}.#{domain}"
      # presumes installation of https://github.com/cogitatio/vagrant-hostsupdater on host
      host.hostsupdater.aliases = ["#{short_name}"]
      # avoinding "Authentication failure" issue
      host.ssh.insert_key = false

      host.vm.provider "virtualbox" do |vb|
        vb.name = "#{short_name}.#{domain}"
        vb.memory = 256
        vb.linked_clone = true
      end

      # create user to do further work with Ansible
      ansible_args = [auto_user_arg].join(" ")
      host.vm.provision "ansible prerequisites", type: "shell", path: "script/ansible_prereqs.sh", args: ansible_args

      # add authorized key to user created by the ansible prereqs script
      authorize_key host, auto_user, auto_key

      # provision db servers
      host.vm.provision "ansible" do |ansible|
        ansible.playbook = "playbooks/provision_db.yml"
        ansible.limit = 'dspace-db-*'
      end

    end
  end

  # # provision db servers
  # config.vm.provision "ansible" do |ansible|
  #   ansible.playbook = "playbooks/provision_db.yml"
  #   ansible.limit = 'dspace-db-dev'
  # end

  # # vm (re)defined here must match a shortname above
  # config.vm.define "app" do |app|
  #   app.vm.provision "ansible" do |ansible|
  #     ansible.playbook = "playbooks/test_ruby.yml"
  #   end
  # end

end
