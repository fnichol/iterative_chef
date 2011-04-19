### Variables

# The directory that the tarballs will be downloaded to.
cache_dir     = "/var/cache/downloads"

# The full URL to download the nginx tarball.
tar_url       = "http://nginx.org/download/nginx-0.9.7.tar.gz"

# The SHA256 checksum for the downloaded file. Chef can check to see if
# the downloaded tarball copy validates and if so it will skip going
# to the network to re-download and verify.
tar_checksum  = "2feb0acee473cc360a620ee862907b9570a4121956c40cbd27da35f5b0a96045"

# The name of the tarball without the URL at the beggining. There is more
# than one way to do this, but splits are fun.
tar_file      = tar_url.split('/').last

# The directory that will get created when extracting the tarball.
# Same string mangling tricks here too but this time using `sub` to strip
# off the file extension.
tar_dir       = tar_file.sub(/\.tar\.gz$/, '')

# The configure flags used when configuring nginx. We're targetting
# a custom directory in `/opt` so that multiple built versions of
# nginx can co-exist together. We're also enabling the SSL module
# which is bound to be used sooner or later.
configure_flags = [
  "--prefix=/opt/#{tar_dir}",
  "--conf-path=/etc/nginx/nginx.conf",
  "--with-http_ssl_module"
]

# A list of Ubuntu packages that must be installed prior to
# compiling nginx. We don't need *wget* anymore as Chef will
# download files for us just fine. The funny `%w{ .. }` is a
# Ruby array of words, so `%w{ one two }` gives you
# `[ "one", "two" ]. Neat, no?
pkgs = %w{ build-essential binutils-doc autoconf flex bison
           libpcre3 libpcre3-dev libssl-dev }

### Install Pre-requisite Packages

# Loop through the `pkgs` array and install each package.
# You are seeing a Ruby block in action here where `pkg`
# is set to the value of the current array element.
#
# The `action` attribute is set to `:install` which is
# actually the default so you can leave it off. But we're
# still learning here, right?
pkgs.each do |pkg|
  package pkg do
    action :install
  end
end

### Fetching and Extraction

# Ensure that the `cache_dir` directory exists and has
# sane permissions and ownership. Again `owner`, `group`,
# and `action` are all defaults (assuming your running chef
# as *root*). The `recursive` attribute ensures that all
# parent directories exist, much like the `-p` flag in
# `mkdir`.
directory cache_dir do
  owner       "root"
  group       "root"
  mode        "0755"
  recursive   true
  action      :create
end

# Download the the nginx tarball into the `cache_dir`
# directory. The name of the `remote_file` resource
# which is `"#{cache_dir}/#{tar_file}"` declares
# the intended target location on your system for this
# file.
#
# The `source` attribute sets up your download URL,
# and the `checksum` attribute makes `remote_file`
# check the downloaded file first. If the checksums
# match, the file will not be re-downloaded. Otherwise,
# it will download this file everytime in order to
# keep it fresh.
remote_file "#{cache_dir}/#{tar_file}" do
  source      tar_url
  checksum    tar_checksum
  owner       "root"
  group       "root"
  mode        "0644"
end

# Next, extract the downloaded tarball into `cache_dir`.
# The `user` and `group` attribute set who is running
# this script and `cwd` sets your *Current Working
# Directory*.
#
# The `execute` resource will fire arbitrary shell commands
# and is not idempotent by default. This means you either
# need to ensure that your command does not have side
# effects if run multiple times or that you use a `not_if`,
# `only_if` or `creates` attribute as a guard.
#
# We're using a `creates` attribute which simply says that
# after `execute` runs, there should be a file or directory
# equal to `"#{cache_dir}/#{tar_dir}"` on the system. The next
# Chef run if this file or directory exists, the command
# will be skipped.
execute "extract nginx tarball" do
  user      "root"
  group     "root"
  cwd       cache_dir
  command   %{tar zxf #{tar_file}}
  creates   "#{cache_dir}/#{tar_dir}"
end

### Compilation and Installation

# The most likely place for something to go wrong :) nginx
# follows a very standard (and sane) build process of running
# `./configure ...`, then `make` and `make install`.
#
# We're using `creates` again so we don't recompile every single
# time Chef runs and there's a special `notifies` attribute
# which we can explain in a minute...
execute "compile nginx" do
  user      "root"
  group     "root"
  cwd       "#{cache_dir}/#{tar_dir}"
  command   %{./configure #{configure_flags.join(' ')} && make && make install}
  creates   "/opt/#{tar_dir}/sbin/nginx"
  notifies  :restart, "service[nginx]"
end

# Now we'll loop through a few directories that need to exist
# for nginx to start. Here is a more traditional Ruby array of
# strings, just to be different.
[ "/var/log/nginx", "/etc/nginx",
  "/etc/nginx/conf.d", "/etc/nginx/sites-enabled"
].each do |dir|
  directory dir do
    owner       "root"
    group       "root"
    mode        "0755"
    recursive   true
    action      :create
  end
end

# A `cookbook_file` is a Chef managed file that will be fetch
# from your cookbook repository. The name of this resource
# is where you want the file installed and the `source` attribute
# is the name of the file stored in your cookbook.
#
# There are some tricks to storing multiple source files for
# different operating systems and platform versions, but that's
# out of scope here.
cookbook_file "/etc/nginx/nginx.conf" do
  source    "nginx.conf"
  owner     "root"
  group     "root"
  mode      "0755"
  notifies  :restart, "service[nginx]"
end

# Same thing with our default nginx site configuration.
cookbook_file "/etc/nginx/sites-enabled/_default.conf" do
  source    "default-site.conf"
  owner     "root"
  group     "root"
  mode      "0755"
  notifies  :restart, "service[nginx]"
end

# Same here with our init.d rc script.
cookbook_file "/etc/init.d/nginx" do
  source    "nginx.init"
  owner     "root"
  group     "root"
  mode      "0755"
  notifies  :restart, "service[nginx]"
end

# Finally we can register a service called `nginx`. By default,
# this corresponds to a system service and is platform dependant.
# In our case with Ubuntu, this is an init.d style service.
#
# Since we are managing our own rc script, we can tell Chef
# what functionality our script supports such as being able to
# restart, reload, and get a status. Setting these values to
# false will cause Chef to use other tricks (possibly grepping
# through `ps` output) to accomplish the same tasks.
#
# Once a serive is registered it can get notified to restart, stop,
# etc. from other Chef resources. This is what the
# `notifies :restart, "service[nginx]` business was about in the
# cookbook files. This is a way to tell Chef: "when is file changes,
# I need you to restart the web server". By default, this
# action is delayed until the end of your Chef run, but you can
# override it if you need it to be immediate.
#
# Finally, we have 2 actions here which is different. We want to
# enable (register with the operating system) and start nginx.
# Fancypants!
service "nginx" do
  supports  :restart => true, :reload => true, :status => true
  action    [ :enable, :start ]
end

# And that's it. Are you still here? I thought you'd be out buying
# a coffee with all this spare time you've freed up.
