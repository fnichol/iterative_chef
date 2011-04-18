begin
  require 'rubygems'
  require 'bundler/setup'

  require 'vagrant'
  require 'virtualbox'
  require 'rake/clean'
  require 'rocco/tasks'
rescue LoadError => ex
  abort ">>> Dependencies could not be loaded (#{ex}). Perhaps try a `bundle install'."
end

def log(msg)
  puts "===> #{msg}"
end

def env
  @env ||= create_env
end

def create_env
  env = Vagrant::Environment.new
  env.ui = Vagrant::UI::Shell.new(env, Thor::Base.shell.new)
  env.load!
  env
end

desc "Bootstrap all virtual machines for action"
task :bootstrap => :prep_master_chef_repo do
  Rake::Task['vm:setup'].invoke(:apt)
  [:manual, :script, :draft, :refactored].each do |name|
    Rake::Task['vm:setup'].reenable
    Rake::Task['vm:setup'].invoke(name)
    Rake::Task['vm:suspend'].reenable
    Rake::Task['vm:suspend'].invoke(name)
    Rake::Task['vm:snapshot'].reenable
    Rake::Task['vm:snapshot'].invoke(name)
  end
  Rake::Task['vm:suspend'].reenable
  Rake::Task['vm:suspend'].invoke(:apt)
  Rake::Task['vm:snapshot'].reenable
  Rake::Task['vm:snapshot'].invoke(:apt)
end

desc "Initializes and updates the master chef-repo"
task :prep_master_chef_repo do
  sh "git submodule init master-chef-repo"
  sh "git submodule update master-chef-repo"
  sh "cd master-chef-repo && git checkout master && rake update"
end

namespace :vm do
  desc "Builds a Vagrant virtual machine"
  task :setup, :vm_name do |t, args|
    vm = env.vms[args[:vm_name].to_sym]
    virtualbox_vm = VirtualBox::VM.find(vm.uuid)

    if vm.created? && vm.saved?
      log "Resuming #{vm.name} host..."
      env.cli "resume", vm.name
      log "#{vm.name} is up."
    elsif vm.created? && virtualbox_vm.running?
      log "#{vm.name} is already running, skipping" and return
    else
      log "Bootstrapping #{vm.name} host..."
      env.cli "up", vm.name
      log "#{vm.name} is up."
    end
  end

  desc "Suspends a Vagrant virtual machine"
  task :suspend, :vm_name do |t, args|
    log "Suspending #{args[:vm_name]} host..."
    env.cli "suspend", args[:vm_name]
    log "#{args[:vm_name]} is suspended."
  end

  desc "Takes a snapshot of a Vagrant virtual machine"
  task :snapshot, :vm_name, :snapshot_name do |t, args|
    args.with_defaults(:snapshot_name => "0-clean")

    vagrant_vm = env.vms[args[:vm_name].to_sym]
    virtualbox_vm = VirtualBox::VM.find(vagrant_vm.uuid)

    if vagrant_vm.created? && virtualbox_vm.running?
      Rake::Task[:suspend].invoke(args[:vm_name])
    end

    log "Taking a snapshot of #{args[:vm_name]} host called 0-clean..."
    virtualbox_vm.take_snapshot(args[:snapshot_name], "Taken by iterative_chef_lab")
    log "Snapshot taken for #{args[:vm_name]}."
  end

  desc "Rolls back a Vagrant virtual machine to a previous snapshot"
  task :rollback, :vm_name, :snapshot_name do |t, args|
    args.with_defaults(:snapshot_name => "0-clean")

    vagrant_vm = env.vms[args[:vm_name].to_sym]
    virtualbox_vm = VirtualBox::VM.find(vagrant_vm.uuid)
    snapshot = virtualbox_vm.find_snapshot(args[:snapshot_name])

    if vagrant_vm.created? && virtualbox_vm.running?
      log "Stopping host #{args[:vm_name]}..."
      virtualbox_vm.stop
      log "#{args[:vm_name]} is off."
    end

    log "Rolling back to snapshot '#{args[:snapshot_name]}' for host #{args[:vm_name]}..."
    snapshot.restore
    log "Rolled back #{args[:vm_name]} to '#{args[:snapshot_name]}'."
  end
end

Rocco::make 'docs/', 'iterations/**/*.sh', { :language => 'bash' }
Rocco::make 'docs/', 'iterations/**/*.json', { :language => 'js' }
Rocco::make 'docs/', 'iterations/**/*.rb'
CLEAN.include 'docs'

desc 'Build rocco docs'
task :docs => :rocco

directory 'docs/'

# GITHUB PAGES ===============================================================

desc 'Update gh-pages branch'
task :pages => ['docs/.git', :docs] do
  rev = `git rev-parse --short HEAD`.strip
  Dir.chdir 'docs' do
    sh "git add *.html"
    sh "git commit -m 'rebuild rocco pages from #{rev}'" do |ok,res|
      if ok
        verbose { puts "gh-pages updated" }
        sh "git push -q o HEAD:gh-pages"
      end
    end
  end
end

# Update the pages/ directory clone
file 'docs/.git' => ['docs/', '.git/refs/heads/gh-pages'] do |f|
  sh "cd docs && git init -q && git remote add o ../.git" if !File.exist?(f.name)
  sh "cd docs && git fetch -q o && git reset -q --hard o/gh-pages && touch ."
end
CLOBBER.include 'docs/.git'
