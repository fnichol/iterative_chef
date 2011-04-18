apt_ip = "192.168.15.10"

Vagrant::Config.run do |config|

  config.vm.box     = "ubuntu-10.10-server-i386"
  config.vm.box_url =
    "http://dl.dropbox.com/u/2297268/ubuntu-10.10-server-i386.box"

  config.vm.define :apt do |apt_config|
    apt_config.vm.host_name     = "apt-cacher.local"

    apt_config.vm.network       apt_ip

    apt_config.vm.provision :chef_solo do |chef|
      chef.cookbooks_path = "master-chef-repo/cookbooks"
      chef.roles_path     = "master-chef-repo/roles"

      if ENV['vdb'] == "1"
        chef.log_level    = :debug
      end

      chef.add_recipe "vagrant_extras"
      chef.add_role   "server"
      chef.add_recipe "apt::cacher"

      chef.json.merge!({
        :rvm => {
          :install_rubies => "disable",
          :upgrade        => "none"
        }
      })
    end
  end

  config.vm.define :manual do |manual_config|
    manual_config.vm.host_name  = "the-manual-way.local"

    manual_config.vm.network        "192.168.15.11"
    manual_config.vm.forward_port   "manual-http", 80, 8081
    manual_config.vm.share_folder   "v-lab", "/lab",
                                    "iterations/the-manual-way"

    manual_config.vm.provision :chef_solo do |chef|
      chef.cookbooks_path = "master-chef-repo/cookbooks"
      chef.roles_path     = "master-chef-repo/roles"

      if ENV['vdb'] == "1"
        chef.log_level    = :debug
      end

      chef.add_recipe "ubuntu"
      chef.add_recipe "vagrant_extras"
      chef.add_role   "base"
      chef.add_recipe "apt"

      chef.json.merge!({
        :ubuntu => {
          :archive_url  => "http://#{apt_ip}:3142/us.archive.ubuntu.com/ubuntu",
          :security_url => "http://#{apt_ip}:3142/security.ubuntu.com/ubuntu"
        },
        :rvm => {
          :install_rubies => "disable",
          :upgrade        => "none"
        }
      })
    end
  end

  config.vm.define :script do |script_config|
    script_config.vm.host_name  = "shell-scripting.local"

    script_config.vm.network        "192.168.15.12"
    script_config.vm.forward_port   "script-http", 80, 8082
    script_config.vm.share_folder   "v-lab", "/lab",
                                    "iterations/shell-scripting"

    script_config.vm.provision :chef_solo do |chef|
      chef.cookbooks_path = "master-chef-repo/cookbooks"
      chef.roles_path     = "master-chef-repo/roles"

      if ENV['vdb'] == "1"
        chef.log_level    = :debug
      end

      chef.add_recipe "ubuntu"
      chef.add_recipe "vagrant_extras"
      chef.add_role   "base"
      chef.add_recipe "apt"

      chef.json.merge!({
        :ubuntu => {
          :archive_url  => "http://#{apt_ip}:3142/us.archive.ubuntu.com/ubuntu",
          :security_url => "http://#{apt_ip}:3142/security.ubuntu.com/ubuntu"
        },
        :rvm => {
          :install_rubies => "disable",
          :upgrade        => "none"
        }
      })
    end
  end

  config.vm.define :draft do |draft_config|
    draft_config.vm.host_name  = "initial-draft.local"

    draft_config.vm.network       "192.168.15.13"
    draft_config.vm.forward_port  "draft-http", 80, 8083
    draft_config.vm.share_folder  "v-lab", "/lab",
                                  "iterations/initial-draft"
    draft_config.vm.share_folder  "v-chef-config", "/etc/chef",
                                  "iterations/initial-draft/config"

    draft_config.vm.provision :chef_solo do |chef|
      chef.cookbooks_path = "master-chef-repo/cookbooks"
      chef.roles_path     = "master-chef-repo/roles"

      if ENV['vdb'] == "1"
        chef.log_level    = :debug
      end

      chef.add_recipe "ubuntu"
      chef.add_recipe "vagrant_extras"
      chef.add_role   "base"
      chef.add_recipe "apt"

      chef.json.merge!({
        :ubuntu => {
          :archive_url  => "http://#{apt_ip}:3142/us.archive.ubuntu.com/ubuntu",
          :security_url => "http://#{apt_ip}:3142/security.ubuntu.com/ubuntu"
        },
        :rvm => {
          :install_rubies => "disable",
          :upgrade        => "none"
        }
      })
    end
  end

  config.vm.define :refactored do |refactored_config|
    refactored_config.vm.host_name  = "refactored-chef.local"

    refactored_config.vm.network        "192.168.15.13"
    refactored_config.vm.forward_port   "refactored-http", 80, 8084
    refactored_config.vm.share_folder   "v-lab", "/lab",
                                        "iterations/refactored"

    refactored_config.vm.provision :chef_solo do |chef|
      chef.cookbooks_path = "master-chef-repo/cookbooks"
      chef.roles_path     = "master-chef-repo/roles"

      if ENV['vdb'] == "1"
        chef.log_level    = :debug
      end

      chef.add_recipe "ubuntu"
      chef.add_recipe "vagrant_extras"
      chef.add_role   "base"
      chef.add_recipe "apt"

      chef.json.merge!({
        :ubuntu => {
          :archive_url  => "http://#{apt_ip}:3142/us.archive.ubuntu.com/ubuntu",
          :security_url => "http://#{apt_ip}:3142/security.ubuntu.com/ubuntu"
        },
        :rvm => {
          :install_rubies => "disable",
          :upgrade        => "none"
        }
      })
    end
  end
end
