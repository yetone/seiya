require 'fileutils'
require 'seiya/version'
require 'seiya/request'
require 'seiya/task'
require 'seiya/item'
require 'seiya/pipeline'
require 'seiya/settings'
require 'seiya/command'
require 'seiya/support'

module Seiya
  extend self

  def process_item(item)
    @pipelines.each do |p|
      item = p.process_item item
    end
  end

  def get_const(require_str, const_str)
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

  def extend_load_path(path)
    Dir.foreach path do |f|
      unless %w(. ..).include? f
        if File.directory? File.join path, f
          new_path = File.join path, f
          extend_load_path new_path
        elsif f == 'tasks.rb'
          $:.unshift path
          break
        end
      end
    end
  end

  def setup(conf_file: 'seiya.ini', load_path: Dir.pwd)
    extend_load_path load_path

    require 'inifile'
    require 'seiya/util'
    conf = IniFile.load conf_file
    settings_file = conf.to_h.fetch('global', {}).fetch('settings', 'settings')
    settings_require_str, settings_const_str = settings_file.split '|'
    require settings_require_str

    pipelines = Settings::PIPELINES
    begin
      pipelines.merge! Util.get_const "#{settings_const_str}::PIPELINES"
    rescue NameError
      # ignored
    end

    pipelines = pipelines.sort_by { |_, v| v }.to_h

    @pipelines = pipelines.keys.map do |k|
      require_str, const_str = k.split '|'
      clazz = get_const require_str, const_str
      clazz.new
    end

    commands = [Settings::COMMANDS]
    begin
      commands << Util.get_const("#{settings_const_str}::COMMANDS")
    rescue NameError
      # ignored
    end

    @commands = commands.map do |dir|
      require_str, const_str = dir.split '|'
      _module = get_const require_str, const_str
      clazz_symbols = _module.constants.select do |c|
        const = _module.const_get(c)
        const.is_a? Class and const < Command
      end
      clazz_symbols.map do |c|
        clazz = _module.const_get c
        [clazz.name.underscore.split('/').last.to_sym, clazz.new]
      end
    end.flatten(1).to_h
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

    @commands[command_sym].run *args
  end

  def get_task_class(task_name)
    task_name = 'Tasks::' << task_name unless task_name.include? '::'
    begin
      Util::get_const task_name
    rescue NameError
      p $:
      puts "Cannot get task: #{task_name}"
      exit!
    end
  end

  def gen_project_file(project_name)
    base_path = "#{project_name}/#{project_name}"
    FileUtils.mkpath "#{base_path}"
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
end))
    File.write("#{base_path}/items.rb", %(require 'items/test'))
    File.write("#{base_path}/pipelines.rb", %(require 'pipelines/test'))
    File.write("#{base_path}/tasks.rb", %(require 'tasks/test'))
    File.write("#{base_path}/items/test.rb",
%(require 'seiya'

module Items
  class Test < Seiya::Item
    def to_s
      inspect
    end
  end
end))
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
end))
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
end))
  end
end
