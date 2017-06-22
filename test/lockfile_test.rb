##
## Lockfile Test
##

assert("Lockfile.new") do
  system "mkdir -p ./tmp"

  t = Lockfile.new "./tmp/test001.lock"
  assert_equal(Lockfile, t.class)

  system "rm -f ./tmp/test001.lock"
end

assert("Lockfile#lock") do
  system "mkdir -p ./tmp"

  t = Lockfile.new "./tmp/test001.lock"
  assert_true(t.lock)
  assert_true(t.lock) # 2 times

  system "rm -f ./tmp/test001.lock"
end

assert("Lockfile#lockwait") do
  system "mkdir -p ./tmp"

  t = Lockfile.new "./tmp/test002.lock"
  assert_true(t.lockwait)

  system "rm -f ./tmp/test002.lock"
end

assert("Lockfile#unlock") do
  system "mkdir -p ./tmp"

  t = Lockfile.new "./tmp/test003.lock"
  assert_true(t.lock)
  assert_true(t.unlock)

  system "rm -f ./tmp/test003.lock"
end

assert("Lockfile#locked?") do
  system "mkdir -p ./tmp"

  t = Lockfile.new "./tmp/test004.lock"
  assert_false(t.locked?)

  t.lock
  # NOTE: Still lockable in current process
  assert_false(t.locked?)

  system "rm -f ./tmp/test004.lock"
end

assert("Lockfile#trylock") do
  system "mkdir -p ./tmp"
  t = Lockfile.new "./tmp/test010.lock"
  assert_true(t.trylock)

  system "rm -f ./tmp/test010.lock"
end
