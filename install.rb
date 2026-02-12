#!/usr/bin/env ruby

require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'

  gem 'colored'
  gem 'terminal-table'
end

require 'colored'
require 'open3'
require 'json'
require 'fileutils'
require 'tempfile'
require 'open-uri'

FORCE_SYMLINKS = false

HOME = File.expand_path("~")
BIN = File.join(HOME, "bin")
LOCAL_PATH = File.expand_path(File.dirname(__FILE__))

DOTFILES = %w(
  profile
  bashrc
  gitconfig
  gitconfig.github
  gitignore
  screenrc
  vimrc
  ackrc
  rubocop.yml
  aliases
  vercomp
  zshrc
  gemrc
).freeze
HOME_DIRECTORIES = %w(
  bin
  dev
  lib
  .atom
).freeze
ATOM_FILES = %w(
  config.cson
  init.coffee
  keymap.cson
  projects.cson
  snippets.cson
  styles.less
).freeze
VSCODE_FILES = %w(
  keybindings.json
  settings.json
  tasks.json
  installed-extensions.txt
  projects.json
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

def install_if_missing(name, version_command, install_command = nil, &block)
  begin
    puts "* Checking for #{name}"
    Open3.popen3(*version_command) do |_stdin, stdout, _stderr, wait_thr|
      if wait_thr.value.success?
        puts "  Found #{name}: #{stdout.read.inspect}".green
        return false
      end
    end
  rescue Errno::ENOENT => e
    puts "  Did not find #{name}: #{e}"
  end

  if block_given?
    unless install_command.nil?
      raise ArgumentError, "expected block or install command but got both"
    end

    block.call
  else
    install(name, install_command)
  end
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
rescue Errno::ENOENT
  raise "Brew not installed"
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

def install_symlink_if_missing(source_file, target_file, attempt: 1)
  if FORCE_SYMLINKS && File.exist?(target_file) && File.symlink?(target_file)
    puts "  " + "Deleting previous symlink #{target_file} -- due to FORCE_SYMLINKS".green.bold
    File.delete(target_file)
  end

  if File.exist?(target_file) && File.symlink?(target_file)
    puts "Not linking file #{source_file} -- already exists".yellow
  elsif File.exist?(target_file) && !File.symlink?(target_file)
    puts "Not linking file #{source_file} -- file already exists at #{target_file}".red
  else
    puts "Linking #{source_file} to #{target_file}".green
    File.symlink(source_file, target_file)
  end
rescue Errno::EEXIST
  if attempt == 1 && FORCE_SYMLINKS
    puts "  " + "Deleting previous symlink #{target_file} -- due to FORCE_SYMLINKS".green.bold
    File.delete(target_file)
    attempt += 1
    retry
  end

  puts "Not linking file #{source_file} -- already exists".yellow
end

# -------- CLI

$steps = []

def step(step_name, options = {}, &block)
  $steps << [step_name, options, block]
end

def run_steps!(*steps)
  puts "steps: #{steps}"
  steps_to_run = steps.length == 0 ?
    $steps.reject { |_, options| options[:disabled] } :
    $steps.select { |name, _| steps.include?(name) }
  puts "steps_to_run: #{steps_to_run}"

  steps_to_run.each do |step_name, _options, block|
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
    source_file = File.join(LOCAL_PATH, dotfile)
    target_file = File.join(HOME, ".#{dotfile}")
    install_symlink_if_missing(source_file, target_file)
  end
end

step 'oh-my-zsh' do
  puts "** Install Oh My Zsh".green

  install_if_missing("oh-my-zsh", ["test", "-d", File.join(HOME, ".oh-my-zsh")]) do
    Tempfile.open('install-oh-my-zsh', '/tmp') do |tempfile|
      URI.open('https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh') do |resp|
        tempfile.write(resp.read)
      end

      tempfile.close

      install("oh-my-zsh", ["sh", tempfile.path])
    end
  end

  puts "** Link my zsh theme files that belongs in ~/.oh-my-zsh".green

  source_file = File.join(LOCAL_PATH, "zsh-theme")
  target_file = File.join(HOME, ".oh-my-zsh/themes/pariser.zsh-theme")
  install_symlink_if_missing(source_file, target_file)
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

  Dir[File.join(LOCAL_PATH, "bin", "*")].each do |source_file|
    target_file = File.join(BIN, File.basename(source_file))
    install_symlink_if_missing(source_file, target_file)
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

  brew_install_if_missing %w()
end

step 'inconsolata' do
  puts "* Checking for inconsolata".green

  output, status = Open3.capture2("system_profiler", "SPFontsDataType")
  unless status.success?
    puts "  Error checking for inconsolata".red
    puts output
    raise
  end

  if output.include?('Inconsolata')
    puts "Inconsolata already installed. Skipping".yellow
    next
  end

  puts ""
  puts "** Instruct on how to install inconsolata".green

  puts "To install inconsolata, download and install from:".red.underline.bold
  puts ""

  puts <<-EOF
    https://fonts.google.com/download?family=Inconsolata
  EOF
end

step 'atom', disabled: true do
  puts "** Link atom config files".green

  ATOM_FILES.each do |atom_file|
    source_file = File.join(LOCAL_PATH, ".atom", atom_file)
    target_file = File.join(HOME, ".atom", atom_file)

    install_symlink_if_missing(source_file, target_file)
  end

  puts ""
  puts "** Instruct on how to install atom packages".green

  # To create a backup file as found in atom-packages.list:
  # apm list --installed --bare > atom-packages.list

  package_file = File.join(LOCAL_PATH, "atom-packages.list")
  install_command = ["apm", "install", "--packages-file", package_file]
  puts "To install atom packages, run:".red.underline.bold
  puts ""
  puts "  #{install_command.join(" ")}"

  puts ""
end

step 'vscode' do
  puts "** Link vscode config files".green

  VSCODE_FILES.each do |vscode_file|
    source_file = File.join(LOCAL_PATH, "vscode", vscode_file)
    target_file = File.join(HOME, "Library/Application Support/Code/User", vscode_file)
    install_symlink_if_missing(source_file, target_file)
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

step 'instruct-restart-shell' do
  puts "** Instruct to restart shell".green

  puts "To ensure that your shell updates and your aliases are registered, run:".red.underline.bold
  puts ""
  puts "  source ~/.zshrc"
  puts "  source ~/.aliases"

  puts ""

end

# -------- various installation steps

if ARGV.include?('-h') || ARGV.include?('--help')
  require 'terminal-table'

  puts Terminal::Table.new({
    headings: ['Install Step', 'Enabled'],
    rows: $steps.map { |name, options, _| [name, !options[:disabled]] },
  })
else
  run_steps! *ARGV
end
