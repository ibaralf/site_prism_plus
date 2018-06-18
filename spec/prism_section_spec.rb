require_relative 'spec_helper'
require 'site_prism'

# USED AS COMPARISON ONLY
# Uses Parent Site Prism for comparison
describe "Original SIte Prism Section" do
  include CapybaraHelper

  class MenuSection < SitePrism::Section
    element :demo, :xpath, '//a[contains(text(), "Demo")]'
    element :order, :xpath, '//a[contains(text(), "Order")]'
    element :order_header, :xpath, '//h2[contains(text(), "Order and Pricing")]'
    element :features, 'span.features'
  end
  class DemoSite < SitePrism::Page
    element :logo, :xpath, '//img[@src="//phptravels.com/assets/img/logo.png"]'
    element :popup_cancel, '#onesignal-popover-cancel-button'
    element :popup_img, :xpath, '//img[@src="https://img.onesignal.com/t/e998c836-a08e-443d-8a04-ae42122635e1.png"]'
    element :popup_box, '#onesignal-popover-dialog'
    element :non_exist, '#doesnotexist'
    section :menu, MenuSection, :xpath, '//a[contains(text(), "Demo")]'
    set_url "https://phptravels.com/demo/"
  end

  let(:demo_site) { DemoSite.new }

  it 'should load demo_site homepage with method load_and_verify' do
    demo_site.load
    demo_site.wait_for_logo
    expect(demo_site).to have_menu
  end

  it 'should not find non_exist element' do
    result = demo_site.wait_until_non_exist_visible
    expect(result).to equal true
  end

  it 'should have allow click_element passing a section element' do
    demo_site.wait_for_popup_cancel
    demo_site.popup_cancel.click
    expect(demo_site).to have_order
  end

  it 'should click section element through page' do
    demo_site.menu.order.click
    expect(demo_site.menu).to have_order_header
  end

  it 'should not find non_exist element' do
    result = demo_site.wait_until_non_exist_visible
    expect(result).to equal true
  end

end
