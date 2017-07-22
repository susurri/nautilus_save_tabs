require 'English'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

CONFIG_DIR = "#{ENV['HOME']}/.config/nautilus".freeze
SCRIPTS_DIR = "#{ENV['HOME']}/.local/share/nautilus/scripts".freeze
SCRIPTS = FileList['scripts/*']
REQUIREMENTS = %w[xdotool nautilus zenity].freeze

task default: 'spec'

desc 'Install'
task 'install' => %w[check install_scripts install_config install_accels] do
  puts 'Done'
end

desc 'Check reqruirements'
task 'check' do
  puts 'Checking requirements'
  REQUIREMENTS.each do |bin|
    `which #{bin}`
    if $CHILD_STATUS.success?
      puts "#{bin}: OK"
    else
      abort "#{bin}: Not Found. please install #{bin}."
    end
  end
end

desc 'Install scripts'
task 'install_scripts' do
  puts 'Installing'
  SCRIPTS.each do |script|
    install script, File.join(SCRIPTS_DIR, File.basename(script, '.rb')),
            mode: 0o755
  end
end

desc 'Install config'
task 'install_config' do
  install 'save_tabs', CONFIG_DIR if File.exist?('save_tabs')
end

desc 'Install accels'
task 'install_accels' do
  install 'scripts-accels', "#{CONFIG_DIR}/scripts-accels"
end
