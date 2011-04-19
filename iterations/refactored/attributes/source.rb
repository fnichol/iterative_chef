default[:nginx][:version]      = "0.9.7"
default[:nginx][:install_path] = "/opt/nginx-#{nginx[:version]}"
default[:nginx][:src_binary]   = "#{nginx[:install_path]}/sbin/nginx"

default[:nginx][:archive_cache] = "/var/cache/downloads/nginx"

default[:nginx][:tar_url] =
  "http://sysoev.ru/nginx/nginx-#{node[:nginx][:version]}.tar.gz"
default[:nginx][:tar_checksum] =
  "2feb0acee473cc360a620ee862907b9570a4121956c40cbd27da35f5b0a96045"

default[:nginx][:packages] = %w{ build-essential binutils-doc autoconf
                                 flex bison libpcre3 libpcre3-dev
                                 libssl-dev }

default[:nginx][:configure_flags] = [
  "--prefix=#{nginx[:install_path]}",
  "--conf-path=#{nginx[:dir]}/nginx.conf",
  "--with-http_ssl_module",
  "--with-http_gzip_static_module"
]
default[:nginx][:extra_configure_flags] = []
