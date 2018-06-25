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
    element :feature_page_header, :xpath, '//h2[contains(text(), "Web App Features")]'
    set_url "https://phptravels.com{/header}"
  end

  let(:demo_site) { DemoSite.new('demo_homepage') }
  let(:documentation) { Documentation.new('documentation_page') }

  it 'should load demo site homepage with method load_and_verify without parametized URL' do
    result = demo_site.load_and_verify('logo')
    expect(result).to equal true
  end

  it 'should load with method load_and_verify with parametized URL' do
    result = demo_site.load_and_verify('feature_page_header', header: 'features')
    expect(result).to equal true
  end

end
