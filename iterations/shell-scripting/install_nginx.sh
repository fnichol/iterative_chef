#!/usr/bin/env bash

### Convenience Functions

# Set up a simple function to print logging info so that the user
# can follow the script output
log() { printf "===> $*\n" ; return $? ; }

# A quick function to handle error-and-quit situtations.
fail()  { printf "\n>> ERROR: $*\n\n" ; exit 1 ; }

# Ensure that the calling user is root and fail otherwise. This
# way we don't need to worry about which commands require sudo.
[[ $UID -ne 0 ]] && fail "You must be root to run this installer"

### Variables

# The directory that tarballs will be downloaded to.
cache_dir="/var/cache/downloads"

# The full URL to download the nginx tarball.
tar_url="http://nginx.org/download/nginx-0.9.7.tar.gz"

# The name of the tarball without the URL at the beggining. There
# is some Bash variable manging going on here with
# [string operators](http://www.linuxjournal.com/article/8919).
tar_file="${tar_url##http*/}"

# The directory that will get created when extracting the tarball.
# Same variable mangling tricks here too (strip `.tar.gz` off the
# end of `$tar_file`).
tar_dir="${tar_file%.tar.gz}"

# The configure flags used when configuring nginx. We're targetting
# a custom directory in `/opt` so that multiple built versions of
# nginx can co-exist together. We're also enabling the SSL module
# which is bound to be used sooner or later.
configure_flags="
  --prefix=/opt/${tar_dir}
  --conf-path=/etc/nginx/nginx.conf
  --with-http_ssl_module
"

# A list of Ubuntu packages that must be installed prior to
# compiling nginx. We also want the *wget* package to fetch
# the tarball. It's installed by default in Ubuntu base, but
# no harm in being explicit.
pkgs=( wget build-essential binutils-doc autoconf flex bison
       libpcre3 libpcre3-dev libssl-dev )

### Install Pre-requisite Packages

# Loop through the `$pkgs` array and install each package
# on its own. We could have done this as one command but
# installing individually might help us catch any errors
# and zero in on the bad package.
log "Installing packages"
for pkg in "${pkgs[@]}" ; do
  log "Installing ${pkg}..."
  apt-get install -y $pkg
done ; unset pkg

### Fetching and Extraction

# Ensure that the `$cache_dir` directory exists and has
# sane permissions and ownership. The `-p` flag in `mkdir`
# will create any missing parent directories.
log "Creating a download cache directory in $cache_dir"
mkdir -p $cache_dir
chown root:root $cache_dir
chmod 755 $cache_dir

# Download the the nginx tarball into the `$cache_dir`
# directory. First, we'll remove any pre-existing tarballs
# so that *wget* won't download the tarball to a different
# file (appending `.1` to the end which is lamesauce for
# our use case).
log "Downloading nginx tarball from $tar_url"
rm -f $cache_dir/$tar_file
(cd $cache_dir && wget $tar_url)

# Next, extract the downloaded tarball into `$cache_dir`
# so we have a place to build it. We'll also kill any
# old extracted directories.
log "Extracting nginx tarball into $cache_dir"
rm -rf $cache_dir/$tar_dir
(cd $cache_dir && tar zxf $tar_file)

### Compilation and Installation

# The most likely place for something to go wrong :) nginx
# follows a very standard (and sane) build process of running
# `./configure ...`, then `make` and `make install`.
log "Building nginx"
(cd $cache_dir/$tar_dir && ./configure $configure_flags)
(cd $cache_dir/$tar_dir && make && make install)

log "Installing /etc/init.d/nginx..."
wget --no-check-certificate \
  'https://gist.github.com/raw/924883/nginx.init.sh' \
  -O /etc/init.d/nginx
chown root:root /etc/init.d/nginx
chmod 755 /etc/init.d/nginx

log "Starting the nginx daemon..."
/usr/sbin/update-rc.d -f nginx defaults
service nginx start

# And that's it, thanks for playing along.
log "Installation of nginx is complete, w00t\!"
