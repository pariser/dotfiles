#!/usr/bin/env ruby

require 'colored'
require 'open3'
require 'json'

HOME = File.expand_path("~")
BIN = File.join(HOME, "bin")
LOCALPATH = File.expand_path(File.dirname(__FILE__))
DOTFILES = %w(profile bashrc gitconfig gitignore screenrc vimrc ackrc).freeze
HOME_DIRECTORIES = %w(bin dev lib .atom).freeze
ATOMFILES = %w(config.cson init.coffee keymap.cson projects.cson snippets.cson styles.less)

def install(name, install_command)
  puts "  Installing #{name}..."
  Open3.popen3(*install_command) do |_stdin, stdout, stderr, wait_thr|
    if wait_thr.value.success?
      puts "  Successfully installed #{name}".green
      return true
    else
      puts "  Error installing #{name}".red
      $stdout.puts stdout.read
      $stderr.puts stderr.read
      raise
    end
  end
end

def install_if_missing(name, version_command, install_command)
  puts "* Checking for #{name}"
  Open3.popen3(*version_command) do |_stdin, stdout, _stderr, wait_thr|
    if wait_thr.value.success?
      puts "  Found #{name}: #{stdout.read.inspect}".green
      return false
    end
  end

  install(name, install_command)
end

def brew_install_if_missing(*names)
  names.flatten.each do |name|
    puts "* Checking for brew package: #{name}"
    output, status = Open3.capture2(*["brew", "info", "--json=v1", name])
    if !status.success?
      puts "  Error checking for brew package: #{name}"
      puts output
      raise
    end

    data = JSON.parse(output)
    if data[0]["installed"].empty?
      install("brew package: #{name}", ["brew", "install", name])
    else
      puts "  Found brew package #{name}: #{data[0]["installed"].to_json}".green
    end
  end
end

puts "\n" + <<-SEPARATOR.green + "\n"
************************************************************
** Link the dotfiles that belong in ~/
SEPARATOR

DOTFILES.each do |dotfile|
  source_file = File.join(LOCALPATH, dotfile)
  target_file = File.join(HOME, ".#{dotfile}")
  if File.exist?(target_file) && File.symlink?(target_file)
    puts "Not linking file #{source_file} -- already exists".yellow
  elsif File.exist?(target_file) && !File.symlink?(target_file)
    puts "Not linking file #{source_file} -- file already exists at #{target_file}".red
  else
    puts "Linking #{source_file} to #{target_file}".green
    File.symlink(source_file, target_file)
  end
end

puts "\n" + <<-SEPARATOR.green + "\n"
************************************************************
** Make bin, dev, lib directories
SEPARATOR

HOME_DIRECTORIES.each do |home_directory|
  target_directory = File.join(HOME, home_directory)

  if File.exist?(target_directory) && File.directory?(target_directory)
    puts "Not creating #{target_directory} -- already exists".yellow
  elsif File.exist?(target_directory)
    puts "Not creating #{target_directory} -- file exists at location!".red
  else
    puts "Creating #{target_directory}".green
    FileUtils.mkdir_p(target_directory)
  end
end

puts "\n" + <<-SEPARATOR.green + "\n"
************************************************************
** Link scripts into ~/bin
SEPARATOR

Dir[File.join(BIN, "*")].each do |source_file|
  basename = File.basename(source_file)
  target_file = File.join(BIN, basename)

  if File.exist?(target_file) && File.symlink?(target_file)
    puts "Not linking file #{source_file} -- already exists".yellow
  elsif File.exist?(target_file)
    puts "Not linking file #{source_file} -- file already exists at #{target_file}".red
  else
    puts "Linking #{source_file} to #{target_file}".green
    File.symlink(source_file, target_file)
  end
end

puts "\n" + <<-SEPARATOR.green + "\n"
************************************************************
** Yarn in ~/bin to satisfy dependencies
SEPARATOR

if File.exist?(File.join(BIN, "package.json"))
  puts "Running `yarn` inside #{BIN}"
  `cd ~/bin && yarn`
end

puts "\n" + <<-SEPARATOR.green + "\n"
************************************************************
** Install homebrew and dependent packages
SEPARATOR

install_if_missing(
  "brew",
  ["brew", "-v"],
  ["/usr/bin/ruby", "-e", '"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"']
)

brew_install_if_missing %w(
  node
  yarn
  bash-completion
  source-highlight
)

puts "\n" + <<-SEPARATOR.green + "\n"
************************************************************
** Link atom config files
SEPARATOR

ATOMFILES.each do |atomfile|
  source_file = File.join(LOCALPATH, ".atom", atomfile)
  target_file = File.join(HOME, ".atom", atomfile)
  if File.exist?(target_file) && File.symlink?(target_file)
    puts "Not linking file #{source_file} -- already exists".yellow
  elsif File.exist?(target_file) && !File.symlink?(target_file)
    puts "Not linking file #{source_file} -- file already exists at #{target_file}".red
  else
    puts "Linking #{source_file} to #{target_file}".green
    File.symlink(source_file, target_file)
  end
end


puts "\n" + <<-SEPARATOR.green + "\n"
************************************************************
** Instruct on how to install atom packages
SEPARATOR

# To create a backup file as found in atom-packages.list:
# apm list --installed --bare > atom-packages.list

package_file = File.join(LOCALPATH, "atom-packages.list")
install_command = ["apm", "install", "--packages-file", package_file]
puts "To install atom packages, run:".red.underline.bold
puts ""
puts "  #{install_command.join(" ")}"


puts ""
