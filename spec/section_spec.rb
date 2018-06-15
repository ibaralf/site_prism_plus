require_relative 'spec_helper'

# NOTES:
# - phptravels.com is a good site to test since it has timing variations.
# - This site's popup notification - after clicking cancel to close the popup, immediate execution
#   of a capybara find will still find the popup. Instances like this dictates adding a needed
#   sleep between closing the popup and checking if the popup is still open
# - Site also contains duplicate locators - caught with Ambiguous match, found 2 elements
describe "Extended Plus Section" do
  include CapybaraHelper

  class MenuSection < SitePrismPlus::Section
    element :demo, :xpath, '//a[contains(text(), "Demo")]'
    element :order, :xpath, '//a[contains(text(), "Order")]'
    element :order_header, :xpath, '//h2[contains(text(), "Order and Pricing")]'
    element :product_menu, :xpath, '//span[contains(text(), "Product")]'
    element :documentation, :xpath, '//a[@href="//phptravels.com/documentation/"]'
    element :doc_header, :xpath, '//h2[contains(text(), "Documentation")]'
    element :features, 'span.features'
  end
  class DemoSite < SitePrismPlus::Page
    element :logo, :xpath, '//img[@src="//phptravels.com/assets/img/logo.png"]'
    element :popup_cancel, '#onesignal-popover-cancel-button'
    element :popup_img, :xpath, '//img[@src="https://img.onesignal.com/t/e998c836-a08e-443d-8a04-ae42122635e1.png"]'
    element :popup_box, '#onesignal-popover-dialog'
    element :popup_allow, '#onesignal-popover-allow-button'
    element :non_existent, '#should-not-be-there'
    section :menu, MenuSection, :xpath, '//a[contains(text(), "Demo")]'
    set_url "https://phptravels.com/demo/"
  end

  let(:demo_site) { DemoSite.new('phptravels.com') }

  it 'should load demo_site homepage with method load_and_verify' do
    result = demo_site.load_and_verify('logo')
    expect(result).to equal true
  end

  it 'should have allow click_element passing a section element' do
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
    expect(is_modal_gone).to equal true
  end

  it 'should find section element through page' do
    result = demo_site.menu.is_element_visible?('demo')
    expect(result).to equal true
  end

  it 'should hover and click section element through page' do
    result = demo_site.menu.hover_and_click('product_menu', 'documentation', 'doc_header')
    expect(result).to equal true
  end

  it 'should log metric for section element through page' do
    demo_site.log_transition_metric('menu.order', 'menu.order_header')
  end



end
