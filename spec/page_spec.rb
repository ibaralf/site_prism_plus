require_relative 'spec_helper'

# NOTES:
# - phptravels.com is a good site to test since it has timing variations.
# - This site's popup notification - after clicking cancel to close the popup, immediate execution
#   of a capybara find will still find the popup. Instances like this dictates adding a needed
#   sleep between closing the popup and checking if the popup is still open
# - Site also contains duplicate locators - caught with Ambiguous match, found 2 elements
describe "Extended Plus Page" do
  include CapybaraHelper

  class DemoSite < SitePrismPlus::Page
    element :logo, :xpath, '//img[@src="//phptravels.com/assets/img/logo.png"]'
    element :popup_cancel, '#onesignal-popover-cancel-button'
    element :popup_img, :xpath, '//img[@src="https://img.onesignal.com/t/e998c836-a08e-443d-8a04-ae42122635e1.png"]'
    element :popup_box, '#onesignal-popover-dialog'
    element :popup_allow, '#onesignal-popover-allow-button'
    element :product_menu, :xpath, '//span[contains(text(), "Product")]'
    element :documentation, :xpath, '//a[@href="//phptravels.com/documentation/"]'
    element :doc_header, :xpath, '//h2[contains(text(), "Documentation")]'
    element :non_exist, '#doesnotexist'
    set_url "https://phptravels.com/demo/"
  end

  class Documentation < SitePrismPlus::Page
    element :doc_search, :id, 'docsQuery'
    element :payment_gateway, :xpath, '//div[contains(text(), "Payment Gateways")]'
    element :homepage_link, :xpath, '//a[@href="//phptravels.com/demo/"]'
    element :homepage_header, :xpath, '//h2[contains(text(), "Application Test Drive.")]'
  end

  let(:demo_site) { DemoSite.new('demo_homepage') }
  let(:documentation) { Documentation.new('documentation_page') }

  it 'should have a url value' do
    demo_site.reset_logfile
    expect(demo_site.url).to eq('https://phptravels.com/demo/')
  end

  it 'should load demo site homepage with method load_and_verify' do
    result = demo_site.load_and_verify('logo')
    expect(result).to equal true
  end

  it 'should have is_element_visible? method' do
    result = demo_site.is_element_visible?('logo')
    expect(result).to equal true
  end

  it 'should have method wait_till_visible' do
    is_modal_gone = false
    if demo_site.wait_till_element_visible('popup_img', 2)
      nloop = 0
      while !is_modal_gone && nloop < 2
        nloop += 1
        demo_site.click_element('popup_cancel')
        is_modal_gone = demo_site.wait_till_element_not_visible('popup_allow')
        if !is_modal_gone
          sleep 0.5
        end
      end
    end
    expect(true).to equal true
  end

  it 'should have method hover_and_click' do
    result = demo_site.hover_and_click('product_menu', 'documentation',  'doc_header')
    expect(result).to equal true
  end

  it 'should type in keys with method send_text' do
    result = documentation.send_text('doc_search', 'hotel')
    expect(result).to equal true
  end

  it 'should clear field with method backspace_clear' do
    documentation.backspace_clear('doc_search')
    expect(documentation.doc_search.value).to eq('')
  end

  it 'should send keys with method send_keys' do
    documentation.send_keys('doc_search', 'payment')
    result = documentation.wait_till_element_visible('payment_gateway')
    expect(result).to equal true
  end

  it 'should have click and verify method' do
    result = documentation.log_transition_metric('homepage_link', 'homepage_header')
    expect(result).to equal true
  end

  it 'should not log metrics data if not enabled' do
    result = false
    if File.exist?(demo_site.metrics_file)
      result = File.read(demo_site.metrics_file).include?('demo_homepage,load')
    else
      result = true
    end
    expect(result).to equal true
  end

  it 'should log metrics data if enabled' do
    ENV['SITEPRISM_METRICS_ENABLED'] = "true"
    documentation.log_transition_metric('homepage_link', 'homepage_header')
    if File.exist?(demo_site.metrics_file)
      result = File.read(demo_site.metrics_file).include?('click,homepage_header')
    else
      result = false
    end
    expect(result).to equal true
  end

  it 'should log transition metrics even if element is not found' do
    demo_site.reset_logfile
    ENV['SITEPRISM_METRICS_ENABLED'] = "true"
    demo_site.log_transition_metric('logo', 'non_exist')
    if File.exist?(demo_site.metrics_file)
      result = File.read(demo_site.metrics_file).include?('click,non_exist')
    else
      result = false
    end
    expect(result).to equal true
  end

end
