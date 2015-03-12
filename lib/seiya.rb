require 'fileutils'
require 'inifile'
require 'seiya/util'
require 'seiya/version'
require 'seiya/request'
require 'seiya/task'
require 'seiya/item'
require 'seiya/pipeline'
require 'seiya/middleware'
require 'seiya/settings'
require 'seiya/command'
require 'seiya/support'
require 'seiya/processer'
require 'seiya/contrib'

module Seiya
  extend self

  def get_const!(require_str, const_str)
    begin
      require require_str
    rescue LoadError => e
      puts e
      puts "Cannot load #{require_str}"
      exit!
    end

    begin
      Util.get_const const_str
    rescue NameError
      puts "Cannot get #{const_str}"
      exit!
    end
  end

  def get_const(require_str, const_str)
    if const_str.nil?
      return Util.get_const require_str
    end
    require require_str
    Util.get_const const_str
  end

  def get_classes(const_path, super_class = Object)
    require_str, const_str = const_path.split '|'
    begin
      _module = get_const require_str, const_str
    rescue LoadError, NameError
      return []
    end

    _module.constants.select do |c|
      const = _module.const_get(c)
      const.is_a? Class and const < super_class
    end.map do |c|
      _module.const_get c
    end
  end

  def get_load_path(path)
    Dir.foreach path do |f|
      if %w(. ..).include? f
        next
      end
      new_path = File.join path, f
      unless File.directory? new_path
        next
      end
      Dir.foreach new_path do |_f|
        if _f == 'tasks.rb'
          return new_path
        end
      end
    end
    nil
  end

  def extend_load_path(path)
    load_path = get_load_path path
    $:.unshift load_path unless load_path.nil?
  end

  def component_instance_variables(*variable_names)
    variable_names.each do |variable_name|
      variable_name = variable_name.to_s
      const_name = variable_name.upcase
      super_class = Seiya.const_get variable_name.sub(/s$/, '').camelize
      vars = Settings.const_get const_name
      begin
        vars.merge! Util.get_const "#{@settings_const_str}::#{const_name}"
      rescue NameError
        # ignored
      end

      vars = {} unless vars.is_a? Hash

      vars = vars.select do |_, v|
        v >= 0
      end.sort_by do |_, v|
        v
      end.to_h

      vars = vars.keys.map do |k|
        require_str, const_str = k.split '|'
        klass = get_const require_str, const_str
        klass.new
      end.select do |p|
        p.is_a? super_class
      end

      instance_variable_set '@' << variable_name, vars
    end
  end

  def setup(conf_file: 'seiya.ini')
    settings_const_str = ''
    if File.exist? conf_file
      path = File.dirname File.expand_path(conf_file)
      extend_load_path path

      conf = IniFile.load conf_file
      settings_file = conf.to_h.fetch('global', {}).fetch('settings', 'settings')
      settings_require_str, settings_const_str = settings_file.split '|'
      @settings_const_str = settings_const_str
      require settings_require_str
    end

    component_instance_variables :pipelines, :request_middlewares

    commands = [Settings::COMMANDS]
    begin
      commands << Util.get_const("#{settings_const_str}::COMMANDS")
    rescue NameError
      # ignored
    end

    @commands = commands.map do |const_path|
      command_classes = get_classes(const_path, Command)
      command_classes.map do |klass|
        [klass.name.underscore.split('/').last.to_sym, klass.new]
      end
    end.flatten(1).to_h

    task_classes = get_classes('tasks|Tasks', Task)
    @task_classes = task_classes.map do |klass|
      [klass.name.underscore.split('/').last.to_sym, klass]
    end.to_h
  end

  def tasks
    if @task_classes.nil?
      setup
    end

    @task_classes.map do |k, v|
      [k, v.summary]
    end.to_h
  end

  def run_command(command, *args)
    if @commands.nil?
      setup
    end

    command_sym = command.to_sym
    unless @commands.key? command_sym
      puts "No command: #{command}"
      exit!
    end

    @commands[command_sym].run! *args
  end

  def usage
    if @commands.nil?
      setup
    end
    available_commands = @commands.map do |k, v|
      '  %-14s%-30s' % [k.to_s, v.summary]
    end.join("\n")

    puts %(Seiya #{VERSION}

Usage:
  seiya <command> [options] [args]

Available commands:
#{available_commands}

Use "seiya <command> -h" to see more info about a command
)
  end

  def get_task_class(task_name)
    if @task_classes.nil?
      setup
    end

    task_name = task_name.to_sym
    unless @task_classes.key? task_name
      puts "Task #{task_name} does not exist!"
      exit!
    end

    @task_classes[task_name]
  end

  def gen_task_file(task_name, task_domain = nil)
    load_path = get_load_path Dir.pwd
    if load_path.nil?
      puts 'Please in a seiya project directory!'
      exit!
    end
    File.open File.join(load_path, 'tasks.rb'), 'a' do |file|
      file.puts "require 'tasks/#{task_name}'"
    end

    task_dir = File.join load_path, 'tasks'
    unless File.exist? task_dir
      FileUtils.mkpath task_dir
    end
    task_file_name = "#{File.join(task_dir, task_name)}.rb"
    if File.exist? task_file_name
      puts "task file: #{task_file_name} exist!"
      exit!
    end
    File.write(task_file_name,
%(require 'seiya'

module Tasks
  class #{task_name.camelize} < Seiya::Task
    def initialize
      @start_urls = [#{task_domain.nil? ? '' : "'#{task_domain}'"}]
    end

    def parse(response, enum)
    end
  end
end
))
  end

  def gen_project_file(project_name)
    base_path = "#{project_name}/#{project_name}"
    FileUtils.mkpath base_path
    FileUtils.mkpath "#{base_path}/tasks"
    FileUtils.mkpath "#{base_path}/items"
    FileUtils.mkpath "#{base_path}/pipelines"

    File.write("#{project_name}/seiya.ini",
%([global]
settings = #{project_name}/settings|Settings
))

    File.write("#{base_path}/settings.rb",
%(module Settings
  PIPELINES = {
      '#{project_name}/pipelines|Pipelines::Test' => 10,
  }
end
))

    File.write("#{base_path}/items.rb", "require 'items/test'\n")

    File.write("#{base_path}/pipelines.rb", "require 'pipelines/test'\n")

    File.write("#{base_path}/tasks.rb", "require 'tasks/test'\n")

    File.write("#{base_path}/items/test.rb",
%(require 'seiya'

module Items
  class Test < Seiya::Item
    def to_s
      inspect
    end
  end
end
))

    File.write("#{base_path}/pipelines/test.rb",
%(require 'seiya'

module Pipelines
  class Test < Seiya::Pipeline
    def process_item(item)
      puts 'I am in Test pipeline!'
      item.to_s
      puts item
      item
    end
  end
end
))

    File.write("#{base_path}/tasks/test.rb",
%(require 'seiya'
require_relative '../items'

module Tasks
  class Test < Seiya::Task
    def initialize
      @start_urls = ['http://www.baidu.com/']
    end

    def parse(response, enum)
      item = Items::Test.new url: response.url
      enum.yield item
    end
  end
end
))

    puts "New Seiya project '#{project_name}' created in:
    #{File.join(Dir.pwd, project_name)}

You can start your first task with:
    cd #{project_name}
    seiya gentask example example.com"
  end
end
