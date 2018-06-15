require 'csv'
# Singleton to capture and log metrics
#
class Metrics

  DEFAULT_METRICS_DIR = Dir.pwd
  DEFAULT_METRICS_FILE = 'metrics.txt'

  attr_accessor :default_log_file, :default_log_directory

  def initialize
    @default_log_directory = DEFAULT_METRICS_DIR
    if ENV['SITEPRISM_PLUS_RESULT_DIR']
      if Dir.exist?(ENV['SITEPRISM_PLUS_RESULT_DIR'])
        @default_log_directory = ENV['SITEPRISM_PLUS_RESULT_DIR']
      end
    else
      results_folder = DEFAULT_METRICS_DIR + '/results'
      unless Dir.exist? (results_folder)
        Dir.mkdir(results_folder)
      end
      @default_log_directory = results_folder
    end
    @default_log_file = @default_log_directory + "/" + DEFAULT_METRICS_FILE
    if ENV['SITEPRISM_PLUS_RESULT_FILE']
      @default_log_file = @default_log_directory + "/" + ENV['SITEPRISM_PLUS_RESULT_FILE']
    end
    @stime = nil
    @etime = nil
  end

  def self.instance
    @@instance
  end

  def clear_file
    if File.exist?(@default_log_file)
      File.delete(@default_log_file)
    end
  end

  def start_time
    @stime = Time.now
  end

  def end_time
    @etime = Time.now
  end

  def log_metric(page, action, tag)
    return unless ENV['SITEPRISM_PLUS_ENABLED']
    @etime = Time.now
    time_laps = @etime - @stime
    CSV.open(@default_log_file, "a") do |csv|
      csv << [page, action, tag, time_laps]
    end
  end

  def log_error_metric(page, action, tag)
    return unless ENV['SITEPRISM_PLUS_ENABLED']
    CSV.open(@default_log_file, "a") do |csv|
      csv << [page, action, tag]
    end
  end

  @@instance = Metrics.new

  private_class_method :new

end