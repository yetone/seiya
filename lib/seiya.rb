require 'fileutils'
require 'seiya/version'
require 'seiya/request'
require 'seiya/task'
require 'seiya/item'
require 'seiya/pipeline'
require 'seiya/settings'

module Seiya
  extend self

  def process_item(item)
    @pipelines.each do |p|
      item = p.process_item item
    end
  end

  def setup(conf_file: 'seiya.ini')
    require 'inifile'
    require 'seiya/util'
    conf = IniFile.load conf_file
    settings_file = conf.to_h.fetch('global', {}).fetch('settings', 'settings')
    settings_require_str, settings_const_str = settings_file.split '|'
    require settings_require_str

    begin
      pipelines = Util.get_const "#{settings_const_str.empty? ? 'Settings' : settings_const_str}::PIPELINES"
    rescue NameError
      pipelines = {}
    end

    pipelines.merge! Settings::PIPELINES

    pipelines = pipelines.sort_by { |_, v| v }.to_h

    @pipelines = pipelines.keys.map do |k|
      require_str, class_name = k.split('|')
      begin
        require require_str
        clazz = Util.get_const class_name
        clazz.new
      rescue LoadError
        puts 'current directory is not a spider directory!'
        exit!
      end
    end
  end

  def get_task(task_name)
    task_name = 'Tasks::' << task_name unless task_name.include? '::'
    clazz = Util::get_const task_name
    clazz.new
  end

  def gen_task_file(task_name)
    base_path = "#{task_name}/#{task_name}"
    FileUtils.mkpath "#{base_path}"
    FileUtils.mkpath "#{base_path}/tasks"
    FileUtils.mkpath "#{base_path}/items"
    FileUtils.mkpath "#{base_path}/pipelines"
    File.write("#{task_name}/seiya.ini",
%([global]
settings = #{task_name}/settings|Settings
))
    File.write("#{base_path}/settings.rb",
%(module Settings
  PIPELINES = {
      '#{task_name}/pipelines|Pipelines::Test' => 10,
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
