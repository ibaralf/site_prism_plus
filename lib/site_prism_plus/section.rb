require 'site_prism'

module SitePrismPlus

  class Section < SitePrism::Section
    include SitePrismPlusCommons

    def set_name(section_name)
      @section_name = section_name
    end

    def log_transition_metric(click_element, verify_element, metric_tag = nil)
      @metrics = Metrics.instance
      @metrics.start_time
      click_element(click_element, verify_element)
      unless metric_tag
        metric_tag = "#{click_element} => #{verify_element}"
      end
      @metrics.log_metric(@section_name, 'click', metric_tag)
    end


    private

  end
end
