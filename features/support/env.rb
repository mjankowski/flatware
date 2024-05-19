# frozen_string_literal: true

require 'pathname'
require 'etc'

$LOAD_PATH.unshift Pathname.new(__FILE__).dirname.join('../../lib').to_s

ENV['PATH'] = [Pathname('.').expand_path.join('bin'), ENV.fetch('PATH', nil)].join(':')

require 'flatware/pid'
require 'aruba/cucumber'
require 'aruba/api'
require 'rspec/expectations'

World(Module.new do
  def max_workers
    Etc.nprocessors
  end
end)

After do |_scenario|
  all_commands.reject(&:stopped?).each do |command|
    zombie_pids = Flatware.pids_of_group(command.pid)

    zombie_pids.each do |pid|
      Process.kill 6, pid
      Process.wait pid, Process::WUNTRACED
    rescue Errno::ECHILD
      next
    end

    expect(zombie_pids).not_to(
      be_any,
      "Zombie pids: #{zombie_pids.size}, should be 0"
    )
  end
end

After 'not @non-zero' do |scenario|
  expect(flatware_process.exit_status).to eq 0 if flatware_process && (scenario.status == :passed)
end

After '@non-zero' do |scenario|
  expect(flatware_process.exit_status).to eq 1 if flatware_process && (scenario.status == :passed)
end
