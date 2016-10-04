# -*- mode: ruby -*-
# vi: set ft=ruby :

require_relative './script/authorize_key'
require 'securerandom'

domain          = "jhu.dev"
auto_user       = "deploy"
auto_user_arg   = "-ou #{auto_user}"
auto_key        = "~/.ssh/dspace_stage.pub"
setup_complete  = false


# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|

  config.vm.box = "centos/7"

  {
    # 'dspace-dev'      => '10.10.20.101',
    # 'dspace-db-dev'   => '10.10.20.102',
    'dspace-stage'    => '10.10.20.103',
    'dspace-db-stage' => '10.10.20.104',
    # 'dspace-prod'     => '10.10.20.105'
    'dspace-db-prod'  => '10.10.20.106'
  }.each do |short_name, ip|
    config.vm.define short_name do |host|
      host.vm.network 'private_network', ip: ip
      host.vm.hostname = "#{short_name}.#{domain}"
      # presumes installation of https://github.com/cogitatio/vagrant-hostsupdater on host
      host.hostsupdater.aliases = ["#{short_name}"]
      # avoinding "Authentication failure" issue
      host.ssh.insert_key = false
      host.vm.synced_folder '.', '/vagrant', disabled: true

      host.vm.provider "virtualbox" do |vb|
        vb.name = "#{short_name}.#{domain}"
        vb.memory = 512
        if short_name.include? "-db-"
          vb.memory = 512
        else
          vb.memory = 1024
        end
        vb.linked_clone = true
      end

      # create user to do further work with Ansible
      ansible_args = [auto_user_arg].join(" ")
      host.vm.provision "ansible prerequisites", type: "shell", path: "script/ansible_prereqs.sh", args: ansible_args

      # add authorized key to user created by the ansible prereqs script
      authorize_key host, auto_user, auto_key

      if short_name == "dspace-db-prod" # last in the list
        setup_complete = true
      end

      if setup_complete
        host.vm.provision "ansible" do |ansible|
          # ansible.verbose = "v"
          ansible.playbook = "playbooks/provision.yml"

          # NOTE: not reading from ansible.cfg
          ansible.inventory_path = "inventory/test_environment"

          # NOTE: can't just leave this out and expect it to default to "all"
          ansible.limit = "all"

          # NOTE: if this doesn't agree with an inventory entry,
          # group_vars may not apply correctly;
          # if it doesn't agree with vagrant's names for things, it won't run.
          # therefore, it's best to specify "all" and filter in the playbooks
          # ansible.limit = "#{short_name}"
        end
      end

    end
  end

  # if setup_complete
  #   # provision db servers
  #   config.vm.provision "ansible" do |ansible|
  #     ansible.playbook = "playbooks/db_provision.yml"
  #     # NOTE: not reading from ansible.cfg
  #     ansible.inventory_path = "inventory/test_environment"
  #     # NOTE: can't just leave this out and expect it to default to "all"
  #     ansible.limit = "all"
  #     # NOTE: if this doesn't agree with an inventory entry,
  #     # group_vars may not apply correctly;
  #     # if it doesn't agree with vagrant's names for things, it won't run.
  #     # therefore, it's best to specify "all" and filter in the playbooks
  #     # ansible.limit = "#{short_name}"
  #   end
  # end

  # # vm (re)defined here must match a shortname above
  # config.vm.define "app" do |app|
  #   app.vm.provision "ansible" do |ansible|
  #     ansible.playbook = "playbooks/test_ruby.yml"
  #   end
  # end

end
