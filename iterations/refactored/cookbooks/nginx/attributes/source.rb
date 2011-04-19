# The default version of nginx that gets downloaded and installed.
# Even if this code base doesn't get updated, you can update
# your node *DNA* JSON file.
default[:nginx][:version]      = "0.9.7"

# The install path for nginx using an attribute already defined.
# If you override the `node[:nginx][:version]` in another place
# (and it wins) then this value gets dynamically updated. In
# other words, you can chain attributes to build new ones.
default[:nginx][:install_path] = "/opt/nginx-#{nginx[:version]}"

# See, how's that for DRY?
default[:nginx][:src_binary]   = "#{nginx[:install_path]}/sbin/nginx"

# There is actually a slightly better way to approach this by
# using a Chef builtin property called `Chef::Config[:file_cache_path]`.
# Just one more way to make your recipes that much more portable.
default[:nginx][:archive_cache] = "/var/cache/downloads/nginx"

# Our download URL again. Now we're interpolating even more to
# keep things DRY and flexible.
default[:nginx][:tar_url] =
  "http://sysoev.ru/nginx/nginx-#{node[:nginx][:version]}.tar.gz"

# What was this again, oh yeah.
default[:nginx][:tar_checksum] =
  "2feb0acee473cc360a620ee862907b9570a4121956c40cbd27da35f5b0a96045"

# We don't get into platform independance in this lab, but there
# is a lot we can do here to make this recipe portable to the Mac,
# debian, arch linux, centos, etc.
default[:nginx][:packages] = %w{ build-essential binutils-doc autoconf
                                 flex bison libpcre3 libpcre3-dev
                                 libssl-dev }

# Here are our default configure flags again.
default[:nginx][:configure_flags] = [
  "--prefix=#{nginx[:install_path]}",
  "--conf-path=#{nginx[:dir]}/nginx.conf",
  "--with-http_ssl_module",
  "--with-http_gzip_static_module"
]

# But this time we've added an additional attribute as a hook.
# We can add other compilation flags in here, without stomping
# on our sane defaults or accidentally killing some of them.
default[:nginx][:extra_configure_flags] = []
