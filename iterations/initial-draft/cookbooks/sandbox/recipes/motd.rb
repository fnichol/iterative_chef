# Creates a custom **Message Of The Day** when a user logs in. A little
# too trivial, but you can see some of Chef's parts nonetheless.

# The **file** resource manages a file an optionally its contents. In
# this case we're setting the contents of the file with the `content`
# attribute. In the real world, most people would set up a **template**
# and manage the file's contents that way (think Ruby on Rails view
# template and you're most of the way there).
file "/etc/motd.tail" do
  owner   "root"
  group   "root"
  action  :create
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
