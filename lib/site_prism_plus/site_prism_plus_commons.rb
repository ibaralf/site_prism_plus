# Common methods to
#    - catch exceptions
#    - run retries
#    - log
# Metrics to capture
#  - click retry
#  - wait till found
module SitePrismPlusCommons

  LOCATOR_TYPES = [:xpath, :css, :id, :name]

  # Finds element on the browser using locator
  # * *Args*    :
  #   - +loc_type_or_element+ -> name of element or locator type (:xpath, :id, ...)
  #   - +locator+ -> syntax for element locator
  # * *Returns* :
  #   - Capybara element object if element is found, nil otherwise
  def find_element(loc_type_or_element, locator = nil)
    ret_elem = nil
    begin
      if LOCATOR_TYPES.include?(loc_type_or_element)
        ret_elem = find(loc_type_or_element, locator)
      else
        ret_elem = eval(loc_type_or_element)
      end
    # rescue Capybara::ElementNotFound
    #   dbg_msg("Finding Element raised ElementNotFound #{loc_type_or_element}", 'error')
    #   return
    # rescue Selenium::WebDriver::Error::StaleElementReferenceError
    #   dbg_msg("Finding Element raised StaleElementReferenceError #{loc_type_or_element}", 'error')
    #   return
    rescue Exception => e
      dbg_msg('error',"Finding Element unexpected exception #{loc_type_or_element} #{e.message}", loc_type_or_element)
      return
    end
    if !ret_elem
      dbg_msg('error',"Finding Element #{loc_type_or_element}NOT FOUND.", loc_type_or_element)
    end
    ret_elem
  end

  # Wraps click call inside begin-rescue to catch possible
  # raised exceptions
  # * *Args*    :
  #   - +element_object+ -> capybara element obj, Capybara::Element
  # * *Returns* :
  #   - true if no exceptions are raised after clicking on element
  #     false if exception is caught
  def is_element_visible?(element_name)
    result = false
    elem_to_check = find_element(element_name)
    unless elem_to_check.nil?
      result = elem_to_check.visible?
    end
    if result
      dbg_msg('info',"Checking Element #{element_name} is_element_visible? - true")
    else
      dbg_msg('info',"Checking if element is visible #{element_name} - false")
    end
    return result
  end

  # Checks till an element is visible or not visible anymore
  #
  def wait_for_visibility(element_name, visible_test = true, max_retry = 3)
    nretry = 0
    res = false
    while nretry < max_retry && !res do
      puts "CHECKING VISIBLE!!!!!!!!!!! #{element_name} result #{res}"
      nretry += 1
      res = is_element_visible?(element_name)
      if !visible_test
        res = !res
      end

      if !res
        puts "WAITING VISIBILITY"
        sleep(1)
      end
    end
    res
  end

  # Just to be more verbose
  def wait_till_element_visible(element_name, n_retry = 3)
    dbg_msg('info',"Wait till element #{element_name} is visible")
    wait_for_visibility(element_name, true, n_retry)
  end

  # Just to be more verbose
  def wait_till_element_not_visible(element_name, n_retry = 3)
    dbg_msg('info',"Wait till element #{element_name} is NOT visible")
    wait_for_visibility(element_name, false, n_retry)
  end

  # Locates an element and clicks it. Verifies if the click action was successful
  # by locating an element that results from the click action. Retries once.
  # * *Args*    :
  #   - +element_name+ -> name of element defined
  #   - +expected_element_name+ -> name of element to verify after the click
  #   - +expected_type+ -> locator type of element to verify
  #   - +expected_locator+ -> syntax for element to verify
  # * *Returns* :
  #   - true if after clicking an element the expected element is found
  #     false otherwise
  def click_element(element_name, expected_element_name = nil)
    result = false
    nretry = 0
    while !result && nretry < 2
      nretry += 1
      elem_to_click = find_element(element_name)
      if elem_to_click
        result = click_action(elem_to_click, element_name)
        dbg_msg('info',"Clicking element - #{element_name}")
        if expected_element_name
          result = is_element_visible?(expected_element_name)
          dbg_msg('info', "Expected element after click: #{expected_element_name} visible? - #{result}")
        end
      end
      if !result && nretry < 2
        dbg_msg('error', "retry_click", element_name)
        sleep(1)
      end
    end
    result
  end

  # Sends text to an input field
  # * *Args*    :
  #   - +element_name+ -> name of element
  #   - +txt_to_send+ -> text (string) to type in input field
  # * *Returns* :
  #   - true if element is found and send_keys successful, false otherwise
  def send_keys(element_name, txt_to_send)
    result = false
    dbg_msg('info', "Send keys to element: #{element_name} - Text: #{txt_to_send}")
    elem_input = find_element(element_name)
    unless elem_input.nil?
      begin
        elem_input.send_keys(txt_to_send)
      rescue Selenium::WebDriver::Error::StaleElementReferenceError
        dbg_msg('error', "StaleElement exception send_keys to element: #{element_name}", element_name)
        return false
      end
      result = true
    end
    return result
  end

  # Use when dealing with auto-complete fields
  # Sends text to an input field one character at a time with a slight
  # delay between characters
  def send_chars(element_name, txt_to_send)
    elem_input = find_element(element_name)
    unless elem_input.nil?
      txt_to_send.chars.each do |onechar|
        begin
          elem_input.send_keys(onechar)
        rescue Selenium::WebDriver::Error::StaleElementReferenceError
          dbg_msg('error', "StaleElement exception send_keys to element: #{element_name}", element_name)
          return false
        end
        sleep(0.5)
      end

      if wait_for_text(element_name, txt_to_send)
        return true
      else
        return false
      end
    end
  end

  # Checks element for value to equal expected text.
  #
  def wait_for_text(element_name, expected_text)
    wait_sec = 0
    while wait_sec < 2
      wait_sec += 1
      element_with_text = find_element(element_name)
      if element_with_text
        found_text = ""
        begin
          found_text = element_with_text.value
          if expected_text == found_text
            return true
          end
        rescue Selenium::WebDriver::Error::StaleElementReferenceError
          dbg_msg('error', "StaleElement exception wait_for_text in element: #{element_name}", element_name)
        end
      end
      sleep(1)
    end
    return false
  end


  # Similar to send_chars, this method auto correct itself if the
  # text is not the same as what was sent
  # - happens with input fields not ready
  # - character send does not register especially with auto-complete fields
  def send_and_verify(element_name, txt_to_send)
    nretry = 0
    while nretry < 2
      nretry += 1
      if send_keys(element_name, txt_to_send)
        if wait_for_text(element_name, txt_to_send)
          return true
        end
      end
      backspace_clear(element_name)
    end
    return false
  end

  # Clears the text inside an input field by sending backspaces
  # * *Args*    :
  #   - +element_name+ -> name of element defined in POM
  # * *Returns* :
  #   - true if element is found, false otherwise
  def backspace_clear(element_name)
    field_element = find_element(element_name)
    if field_element
      field_text = field_element.value
      (0..field_text.size).each do
        send_keys(element_name, :backspace)
      end
    else
      return false
    end
    true
  end

  # Routine for hover activated dropdown menus
  # * *Args*    :
  #   - +hover_elem+ -> POM defined element to move mouse over
  #   - +click_elem+ -> POM defined element to click
  #   - +expected_elem+ -> resulting POM defined element to verify
  # * *Returns* :
  #   - true if element is found, false otherwise
  def hover_and_click(hover_elem, click_elem, expected_elem = nil)
    result = false
    helem = find_element(hover_elem)
    if helem
      dbg_msg('info', "Hovering over #{hover_elem}")
      helem.hover
    end
    if wait_till_element_visible(click_elem)
      result = click_element(click_elem, expected_elem)
    end
    result
  end

  private

  # Wraps click call inside begin-rescue to catch possible
  # raised exceptions
  # * *Args*    :
  #   - +element_object+ -> capybara element obj, Capybara::Element
  # * *Returns* :
  #   - true if no exceptions are raised after clicking on element
  #     false if exception is caught
  def click_action(element_object, element_name)
    begin
      element_object.click
    # rescue Selenium::WebDriver::Error::StaleElementReferenceError
    #   dbg_msg('error', "Stale Element exception - click_element")
    #   return false
    # rescue Selenium::WebDriver::Error::UnknownError
    #   dbg_msg('error', "Unknown error exception - click_element")
    #   return false
    rescue Exception => e
      dbg_msg('error', 'click_exception', element_name)
      return false
    end
    true
  end

  def dbg_msg(dlevel, msg, msg_tag = nil)
    case dlevel.downcase
      when 'info'
        puts "INFO: #{msg}" if ENV['SITEPRISM_PLUS_DEBUG']
      when 'error'
        puts "ERROR: #{msg}" if ENV['SITEPRISM_PLUS_DEBUG']
        log_metric(@page_name, msg, msg_tag) if ENV['SITEPRISM_METRICS_ENABLED']
    end
  end

  # Log error or retry events
  def log_metric(page, action, error_tag)
    @metric = Metrics.instance
    @metric.log_error_metric(page, action, error_tag)
  end

end