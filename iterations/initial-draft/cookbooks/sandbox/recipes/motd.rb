# Creates a custom **Message Of The Day** when a user logs in. A little
# too trivial, but you can see some of Chef's parts nonetheless.

# The **file** resource manages a file an optionally its contents. In
# this case we're setting the contents of the file with the `content`
# attribute. In the real world, most people would set up a **template**
# and manage the file's contents that way (think Ruby on Rails view
# template and you're most of the way there).
#
# For more details about how this resource works, consult the Chef
# [resources][re] wiki page.
#
# [re]: http://wiki.opscode.com/display/chef/Resources#Resources-File
file "/etc/motd.tail" do

  # This will be the owner of the file. We're being a bit explicit here.
  owner   "root"

  # This will be the group ownership of the file. Woah.
  group   "root"

  # This is the default action, to create the file. Other possible
  # actions are `:delete` to ensure the file is deleted and `:touch`
  # to update the file's mtime and atime on each run.
  action  :create

  # The contents of our file. The `node[:xxx]` parts will use the
  # dynamic system values determined by Chef at runtime (using the
  # [Ohai][oh] gem).
  #
  # [oh]: http://wiki.opscode.com/display/chef/Ohai
  content <<-MOTD.gsub(/^ {4}/, '')

    ============================================================
      Hello, World!
      Welcome to #{node[:fqdn]} running #{node[:platform].capitalize}

      Your server is being tenderly cared for thanks to Chef
      version #{node[:chef_packages][:chef][:version]}.

      Enjoy yourself, and use all #{node[:memory][:total]} of your RAM.
    ============================================================

  MOTD
end
