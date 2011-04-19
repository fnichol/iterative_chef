# Which install strategy do we want? Would most people want a source
# based install or a package based install?
#
# If you're building with others in mind, these questions come up.
# It's not all that different from building a library or API. You
# are setting default behavior which saves time and mental load
# (think Rails here), but you want to be flexible enough so that
# others can have their way.
#
# Given the likely user will be using passenger, unicorn or some
# Ruby based server component we're going to default to source based.
default[:nginx][:flavor] = "source"
