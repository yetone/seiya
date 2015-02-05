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
    require settings_file

    begin
      pipelines = ::Settings::PIPELINES
    rescue NameError
      pipelines = {}
    end

    pipelines.merge! Settings::PIPELINES

    pipelines = pipelines.sort_by { |_, v| v }.to_h

    @pipelines = pipelines.keys.map do |k|
      require_str, class_name = k.split('|')
      require require_str
      clazz = Util.get_const class_name
      clazz.new
    end
  end

  def get_task(task_name)
    task_name = 'Tasks::' << task_name unless task_name.include? '::'
    clazz = Util::get_const task_name
    clazz.new
  end
end
