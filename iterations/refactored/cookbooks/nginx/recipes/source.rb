cache_dir     = node[:nginx][:archive_cache]
tar_url       = node[:nginx][:tar_url]
tar_checksum  = node[:nginx][:tar_checksum]
tar_file      = tar_url.split('/').last
tar_dir       = tar_file.sub(/\.tar\.gz$/, '')

unless node[:nginx][:extra_configure_flags].empty?
  node[:nginx][:configure_flags].push(
    *node[:nginx][:extra_configure_flags])
end
configure_flags = node[:nginx][:configure_flags]

pkgs = node[:nginx][:packages]

pkgs.each do |pkg|
  package pkg
end

directory cache_dir do
  mode        "0755"
  recursive   true
end

remote_file "#{cache_dir}/#{tar_file}" do
  source      tar_url
  checksum    tar_checksum
  mode        "0644"
end

execute "extract nginx tarball" do
  cwd       cache_dir
  command   %{tar zxf #{tar_file}}
  creates   "#{cache_dir}/#{tar_dir}"
end

execute "compile nginx" do
  user      "root"
  group     "root"
  cwd       "#{cache_dir}/#{tar_dir}"
  command   %{./configure #{configure_flags.join(' ')} && make && make install}
  only_if do
    any_missing = false
    configure_flags.each do |flag|
      result = %x{
        if #{nginx_install}/sbin/nginx -V 2>&1 | grep -q -- "#{flag}" ; then
          echo found
        fi
      }
      any_missing = true unless result.chomp == "found"
    end
    if any_missing
      true
    else
      creates node[:nginx][:src_binary]
      false
    end
  end
end

[ "/var/log/nginx", "/etc/nginx",
  "/etc/nginx/conf.d", "/etc/nginx/sites-enabled"
].each do |dir|
  directory dir do
    owner       "root"
    group       "root"
    mode        "0755"
    recursive   true
  end
end

template "/etc/nginx/nginx.conf" do
  source    "nginx.conf.erb"
  owner     "root"
  group     "root"
  mode      "0755"
  notifies  :restart, "service[nginx]"
end

template "/etc/nginx/sites-enabled/_default.conf" do
  source    "default-site.conf.erb"
  owner     "root"
  group     "root"
  mode      "0755"
  notifies  :restart, "service[nginx]"
end

template "/etc/init.d/nginx" do
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
