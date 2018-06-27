require 'site_prism'
require_relative 'metrics'
require_relative 'site_prism_plus_commons'

# Extends SitePrism Page class to include common methods
# and logging metrics
module SitePrismPlus

  class Page < SitePrism::Page
    include SitePrismPlusCommons

    attr_accessor :page_name

    def initialize(pname = nil)
      if pname
        @page_name = pname
      else
        @page_name = self.class.to_s
      end
      @metrics = Metrics.instance
    end

    # Page loads typically takes longer.
    def load_and_verify(verify_element, url_hash = nil)
      result = true
      @metrics.start_time
      if url_hash.nil?
        load
      else
        load(url_hash)
      end
      if verify_element
        result = wait_till_element_visible(verify_element, 3)
      end
      @metrics.log_metric(@page_name, 'load', verify_element)
      result
    end

    def log_transition_metric(click_element, verify_element)
      @metrics.start_time
      result = click_element(click_element, verify_element)
      @metrics.log_metric(@page_name, 'click', verify_element)
      result
    end

    def reset_logfile
      @metrics.clear_file
    end

    def metrics_file
      @metrics.default_log_file
    end

  end
end
