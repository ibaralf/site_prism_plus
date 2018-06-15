require 'site_prism'
require_relative 'metrics'
require_relative 'site_prism_plus_commons'

# Extends SitePrism Page class to include common methods
# and logging metrics
module SitePrismPlus

  class Page < SitePrism::Page
    include SitePrismPlusCommons

    def initialize(page_name)
      @page_name = page_name
      @metrics = Metrics.instance
    end

    # Page loads typically takes longer.
    def load_and_verify(element_name)
      load_override(element_name)
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

    private

    def load_override(verify_element = nil)
      result = true
      @metrics.start_time
      load
      if verify_element
        result = wait_till_element_visible(verify_element, 3)
      end
      @metrics.log_metric(@page_name, 'load', verify_element)
      result
    end

  end
end
