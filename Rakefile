require 'rubygems'
require 'vagrant'

def log(msg)
  puts "===> #{msg}"
end

desc "Bootstrap all virtual machines for action"
task :bootstrap do
  env = Vagrant::Environment.new

  apt = env.vms[:apt]

  if apt.created? && apt.saved?
    log "Resuming apt host..."
    env.cli "resume", "apt"
  else
    log "Bootstrapping apt host..."
    env.cli "up", "apt"
  end
  log "apt up and running."

  [:manual, :script, :draft, :refactored].each do |name|
    vm = env.vms[name]

    if vm.created? && vm.saved?
      log "Resuming #{name} host..."
      env.cli "resume", name
    else
      log "Bootstrapping #{name} host..."
      env.cli "up", name
    end
    log "#{name} is up."
    log "Suspending #{name} host..."
    env.cli "suspend", name
    log "#{name} is suspended."
  end

  log "Suspending apt host..."
  env.cli "suspend", "apt"
  log "apt is suspended."
end
