# Now we can set the attribute of `nginx/flavor` if we want a
# package-based installation. By not specifying anything we
# get a source based installation.
include_recipe "chef::#{node[:nginx][:flavor]}"
