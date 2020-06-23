#!/usr/bin/env ruby

require 'colored'
require 'open3'
require 'json'
require 'fileutils'

HOME = File.expand_path("~")
BIN = File.join(HOME, "bin")
LOCALPATH = File.expand_path(File.dirname(__FILE__))

DOTFILES = %w(
  profile
  bashrc
  gitconfig
  gitignore
  screenrc
  vimrc
  ackrc
  rubocop.yml
  aliases
  vercomp
  zshrc
).freeze
HOME_DIRECTORIES = %w(
  bin
  dev
  lib
  .atom
).freeze
ATOMFILES = %w(
  config.cson
  init.coffee
  keymap.cson
  projects.cson
  snippets.cson
  styles.less
).freeze
VSCODEFILES = %w(
  keybindings.json
  settings.json
  tasks.json
  installed-extensions.txt
).freeze

# -------- utilities

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

def check_brew_info(name)
  puts "* Checking for brew package: #{name}"
  output, status = Open3.capture2("brew", "info", "--json=v1", name)
  unless status.success?
    puts "  Error checking for brew package: #{name}"
    puts output
    raise
  end
  output
end

def parse_brew_output(name, output)
  data = JSON.parse(output)
  if data[0]["installed"].empty?
    install("brew package: #{name}", ["brew", "install", name])
  else
    puts "  Found brew package #{name}: #{data[0]["installed"].to_json}".green
  end
end

def brew_install_if_missing(*names)
  names.flatten.each do |name|
    output = check_brew_info(name)
    parse_brew_output(name, output)
  end
end

# -------- CLI

$steps = []

def step(step_name, &block)
  $steps << [step_name, block]
end

def run_steps!(*steps)
  puts "steps: #{steps}"
  steps_to_run = steps.length == 0 ?
    $steps :
    $steps.select { |name, _| steps.include?(name) }
  puts "steps_to_run: #{steps_to_run}"

  steps_to_run.each do |step_name, block|
    puts "\n" + <<~SEPARATOR.green + "\n"
      ************************************************************
      RUNNING STEP: #{step_name}
    SEPARATOR

    block.call
  end
end

# -------- various installation steps

step 'dotfiles' do
  puts "** Link the dotfiles that belong in ~/".green

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
end

step 'directories' do
  puts "** Make bin, dev, lib directories".green

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
end

step 'bin-scripts' do
  puts "** Link scripts into ~/bin".green

  Dir[File.join(LOCALPATH, "bin", "*")].each do |source_file|
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
end

step 'yarn' do
  puts "** Yarn in ~/bin to satisfy dependencies".green

  if File.exist?(File.join(BIN, "package.json"))
    puts "Running `yarn` inside #{BIN}"
    `cd ~/bin && yarn`
  end
end

step 'brew' do
  puts "** Install homebrew".green

  install_if_missing(
    "brew",
    [
      "brew",
      "-v",
    ],
    [
      "/usr/bin/ruby",
      "-e",
      '"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"',
    ]
  )
end

step 'brew-deps' do
  puts "** Install dependent packages from homebrew".green

  brew_install_if_missing %w(
    node
    yarn
    bash-completion
    source-highlight
  )
end

step 'atom' do
  puts "** Link atom config files".green

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

  puts ""
  puts "** Instruct on how to install atom packages".green

  # To create a backup file as found in atom-packages.list:
  # apm list --installed --bare > atom-packages.list

  package_file = File.join(LOCALPATH, "atom-packages.list")
  install_command = ["apm", "install", "--packages-file", package_file]
  puts "To install atom packages, run:".red.underline.bold
  puts ""
  puts "  #{install_command.join(" ")}"

  puts ""
end

step 'vscode' do
  puts "** Link vscode config files".green

  VSCODEFILES.each do |vscodefile|
    source_file = File.join(LOCALPATH, "vscode", vscodefile)
    target_file = File.join(HOME, "Library/Application Support/Code/User", vscodefile)
    if File.exist?(target_file) && File.symlink?(target_file)
      puts "Not linking file #{source_file} -- already exists".yellow
    elsif File.exist?(target_file) && !File.symlink?(target_file)
      puts "Not linking file #{source_file} -- file already exists at #{target_file}".red
    else
      puts "Linking #{source_file} to #{target_file}".green
      File.symlink(source_file, target_file)
    end
  end


  puts ""
  puts "** Instruct on how to install vscode packages".green

  # To update the list of installed extensions, run the following command:
  #
  #    code --list-extensions > ~/Library/Application\ Support/Code/User/installed-extensions.txt
  #

  puts "To install vscode packages, run:".red.underline.bold
  puts ""

  puts <<-EOF
    cat ~/Library/Application\\ Support/Code/User/installed-extensions.txt | xargs -L1 code --install-extension
  EOF

  puts ""
end

# -------- various installation steps

if ARGV.include?('-h') || ARGV.include?('--help')
  puts "Available steps: #{$steps.map { |name, _| name }.join(", ")}"
else
  run_steps! *ARGV
end
