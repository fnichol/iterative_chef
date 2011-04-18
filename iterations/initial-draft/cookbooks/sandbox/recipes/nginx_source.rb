cache_dir     = "/var/cache/downloads"
tar_url       = "http://nginx.org/download/nginx-0.9.7.tar.gz"
tar_checksum  = "2feb0acee473cc360a620ee862907b9570a4121956c40cbd27da35f5b0a96045"
tar_file      = tar_url.split('/').last
tar_dir       = tar_file.sub(/\.tar\.gz$/, '')

configure_flags = [
  "--prefix=/opt/#{tar_dir}",
  "--conf-path=/etc/nginx/nginx.conf",
  "--with-http_ssl_module"
]

pkgs = %w{ wget build-essential binutils-doc autoconf flex bison
           libpcre3 libpcre3-dev libssl-dev }

pkgs.each do |pkg|
  package pkg do
    action :install
  end
end

directory cache_dir do
  owner       "root"
  group       "root"
  mode        "0755"
  recursive   true
  action      :create
end

remote_file "#{cache_dir}/#{tar_file}" do
  source      tar_url
  checksum    tar_checksum
  owner       "root"
  group       "root"
  mode        "0644"
end

execute "extract nginx tarball" do
  user      "root"
  group     "root"
  cwd       cache_dir
  command   %{tar zxf #{tar_file}}
  creates   "#{cache_dir}/#{tar_dir}"
end

execute "compile nginx" do
  user      "root"
  group     "root"
  cwd       "#{cache_dir}/#{tar_dir}"
  command   %{./configure #{configure_flags.join(' ')} && make && make install}
  creates   "/opt/#{tar_dir}/sbin/nginx"
  notifies  :restart, "service[nginx]"
end

directory "/var/log/nginx" do
  owner       "root"
  group       "root"
  mode        "0755"
  recursive   true
  action      :create
end

directory "/etc/nginx" do
  owner       "root"
  group       "root"
  mode        "0755"
  recursive   true
  action      :create
end

directory "/etc/nginx/conf.d" do
  owner       "root"
  group       "root"
  mode        "0755"
  recursive   true
  action      :create
end

directory "/etc/nginx/sites-enabled" do
  owner       "root"
  group       "root"
  mode        "0755"
  recursive   true
  action      :create
end

cookbook_file "/etc/nginx/nginx.conf" do
  source    "nginx.conf"
  owner     "root"
  group     "root"
  mode      "0755"
  notifies  :restart, "service[nginx]"
end

cookbook_file "/etc/nginx/sites-enabled/_default.conf" do
  source    "default-site.conf"
  owner     "root"
  group     "root"
  mode      "0755"
  notifies  :restart, "service[nginx]"
end

cookbook_file "/etc/init.d/nginx" do
  source    "nginx.init"
  owner     "root"
  group     "root"
  mode      "0755"
  notifies  :restart, "service[nginx]"
end

service "nginx" do
  supports  :restart => true, :reload => true, :status => true
  action    [ :enable, :start ]
end
