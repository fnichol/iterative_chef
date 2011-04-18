# **chef-solo configuration files** will cut down on the amount of command
# line arguments you need to pass to chef-solo. With the following
# configuration, you could just issue `chef-solo` and you're off to the
# races. By default, *chef-solo* will look for a `solo.rb` file at
# `/etc/chef/solo.rb`. To override this pass it the `-c <path>` argument,
# for example:
#
# chef-solo -c /etc/chef/solo.rb -j /etc/chef/dna.json
#
# For more gory details or to further tweak your defaults, check out the
# [Chef Configuration Settings][cfg] wiki page.

# As quoted from the [reference][ref]: *"Where to locally store cache
# files like cookbooks and other transient data"*. So uh, yeah... just
# set a temporary path here and move along.
#
# [cfg]: http://wiki.opscode.com/display/chef/Chef+Configuration+Settings
# [ref]: http://wiki.opscode.com/display/chef/Chef+Configuration+Settings#ChefConfigurationSettings-filecachepath
file_cache_path   "/tmp/chef-solo"

# The location chef-solo goes looking for chef cookbooks. This could also
# be a list if there are multiple directories. A list, however does not
# appear to be used much in the [wild][wi]
#
# [wi]: https://twitter.com/#!/mitchellh/status/57539400908808192
coobook_path      "/lab/cookbooks"

# The path to your JSON attributes. Also widely known as your Chef *DNA*.
# There's where you are customizing want you want configured and tweak
# attribute settings (like listing users, packages, versions, etc.).
json_attribs      "/etc/chef/dna.json"

# The default log level for a *chef-solo* execution. `:info` will give
# you a nice resource-leve description of what is going on (i.e.
# *"Creating file[/etc/cool/mojo.cnf] at /etc/cool/mojo.cnf"* or
# *"Setting mode to 644 for file[/etc/cool/mojo.cnf]"*).
#
# For development and troubleshooting, I'd recommend getting used to the
# `:debug` level output. You'll see exactly what commands get executed,
# if it's skipping resources, the order it loads cookbooks, etc.
#
# To increase the verbosity of logging for a one-off execution, pass
# *chef-solo* `-l debug` as an argument.
log_level         :info

# You can redirect the log output to a file or `STDOUT`. `STDOUT` may
# not be the ideal in production as you might want to have a log of what
# happened when (this can be very useful for audits or blames).
log_location      STDOUT
