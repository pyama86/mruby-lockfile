require 'open3'

MRUBY_BIN_PATH = File.join(File.dirname(__FILE__), "../mruby/bin/mruby") unless defined?(MRUBY_BIN_PATH)

if File.exist? MRUBY_BIN_PATH # Only in mgem's CI

assert('lock from another process') do
  system "mkdir -p tmp"
  system %Q(#{MRUBY_BIN_PATH} -e "Lockfile.lock './tmp/test101.lock'; loop {}" &)
  sleep 0.01
  output, err, status = Open3.capture3(MRUBY_BIN_PATH, "-e", "Lockfile.lock './tmp/test101.lock'")

  assert_false status.success?
  assert_true err.include? 'cannot set lock'

  system "killall mruby"
  system "rm -f './tmp/test101.lock'"
end

assert('lockwait for another lock released') do
  system "mkdir -p tmp"
  system %Q(#{MRUBY_BIN_PATH} -e "Lockfile.lock './tmp/test102.lock'; sleep 1" &)
  sleep 0.01
  output, err, status = Open3.capture3(MRUBY_BIN_PATH, "-e", "Lockfile.lockwait './tmp/test102.lock'")

  assert_true status.success?

  system "killall mruby 2>/dev/null || true"
  system "rm -f './tmp/test102.lock'"
end

assert('trylock output') do
  system "mkdir -p tmp"
  output, err, status = Open3.capture3(MRUBY_BIN_PATH, "-e", "l = Lockfile.new './tmp/test103.lock'; puts l.trylock.to_s")
  assert_equal "true", output.chomp

  system %Q(#{MRUBY_BIN_PATH} -e "Lockfile.lock './tmp/test103.lock'; loop {}" &)
  sleep 0.01
  output, err, status = Open3.capture3(MRUBY_BIN_PATH, "-e", "l = Lockfile.new './tmp/test103.lock'; puts l.trylock.to_s")
  assert_equal "false", output.chomp

  system "killall mruby"
  system "rm -f './tmp/test103.lock'"
end

assert('lockwait with unlock') do
  system "mkdir -p tmp"
  system %Q(#{MRUBY_BIN_PATH} -e "l = Lockfile.lock './tmp/test104.lock'; usleep 20*1000; l.unlock; loop {}" &)
  sleep 0.01
  output, err, status = Open3.capture3(MRUBY_BIN_PATH, "-e", "Lockfile.lockwait './tmp/test104.lock'")

  assert_true status.success?

  system "killall mruby"
  system "rm -f './tmp/test104.lock'"
end

assert('get pid of locker') do
  system "mkdir -p tmp"
  system %Q(#{MRUBY_BIN_PATH} -e "Lockfile.lock './tmp/test105.lock'; loop {}" &)
  sleep 0.01
  output, err, status = Open3.capture3(MRUBY_BIN_PATH, "-e", "p Lockfile.new('./tmp/test105.lock').locking_pid")

  assert_true output.to_i > 0

  system "killall mruby"
  system "rm -f './tmp/test105.lock'"
end

end
