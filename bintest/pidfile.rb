require 'open3'

MRUBY_BIN_PATH = File.join(File.dirname(__FILE__), "../mruby/bin/mruby") unless defined?(MRUBY_BIN_PATH)

if File.exist? MRUBY_BIN_PATH # Only in mgem's CI

assert('pid lock from another process') do
  system "mkdir -p tmp"
  system %Q(#{MRUBY_BIN_PATH} -e "Pidfile.create './tmp/test101.pid'; loop {}" &)
  sleep 0.01
  output, err, status = Open3.capture3(MRUBY_BIN_PATH, "-e", "Pidfile.create './tmp/test101.pid'")

  assert_false status.success?
  assert_true err.include? 'cannot set lock'

  pid = File.read './tmp/test101.pid'
  assert_true pid.to_i > 0

  system "killall mruby"
  system "rm -f './tmp/test101.pid'"
end

end
