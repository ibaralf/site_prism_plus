# SitePrismPlus

###THIS IS NOT PUBLISHED YET.

Extends the page object model [site_prism ruby gem](https://github.com/natritmeyer/site_prism). It adds common methods to make test execution robust. The gem also can log events such as click errors or page load times into a flat file.

Dynamic single page applications are getting difficult to test usually caused by timing issues resulting in raised 
exceptions. Automation frameworks or util libraries are typically written to catch these exceptions and handled accordingly. Site Prism 
is a great POM framework so it's quite useful extend it and put your utils.

## Installation

###THIS IS NOT PUBLISHED YET.

Add this line to your application's Gemfile:

```ruby
gem 'site_prism_plus'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install site_prism_plus

## Usage

```ruby
class DemoSite < SitePrismPlus::Page
  set_url 'https://some_site.com'
  
  element :header_logo, :xpath, '//img[@src="some_source"]'
  element :sub_link, '#link_id'
  element :click_result_elem, '#some_elem_loc'
  element :name_input_field, '#user_name'
  element :search_input, '#q_search'
end
```

#### Loading the page and verify element
Loads the page and verifies if the element expected is present. Method __load_and_verify__ takes an element 
as a parameter. The page is loaded and the element is checked until visible.
```ruby
demo_site = DemoSite.new('page_description')
demo_site.load('header_logo')
```

#### Clicking an element
Clicking an element sometimes results in exceptions such as StateElement. Method __click_element__ catches 
exceptions and does a retry. If a second element is passed as a parameter, it verifies this second element 
to determine if the click action was successful.
```ruby
demo_site.click_element('sub_link', 'click_result_elem')
```

#### Send keys and verify
For input fields with auto-complete or has match recommendation, sending keys to the field sometimes results with several 
issues. Method __send_and_verify__ sends the text to an input field and verifies field has the correct text. If not
field is cleared and text is resent.
```ruby
demo_site.send_and_verify('name_input_field', 'some_user_name')
```

#### Send chars
Sends text to an input field one character at a time with a slight delay between characters. Useful when checking for 
auto-complete or search matching. 
```ruby
demo_site.send_chars('search_input', 'cheap flights')
```

#### Checking Visibility
Returns true or false if an element is found and is visible. Catches possible exceptions 
(ex. SitePrism::TimeOutWaitingForElementVisibility:).
* is_element_visible('name_of_element')
* wait_till_element_visible('name_of_element')
* wait_till_element_not_visible('name_of_element')
```ruby
demo_site.wait_till_element_visible('header_logo')
```

#### Hover and click
Useful for hover activated drop downs. An optional third parameter (expected_element) can be passed. This element will
be verified to determine if the click was successful.
```ruby
demo_site.hover_and_click('hover_element', 'drop_option')

# or
 
demo_site.hover_and_click('hover_element', 'drop_option', 'resulting_element')
```

### Sections
All methods in Page are available for Section. See RSpec tests in spec folder for examples.

## Capturing Some Test Metrics
Lots of open source and commercial applications out there to capture metrics for your web application, this gem 
just captures test related metrics such as click retries, page loads, or transitions times (like modals). These metrics are 
saved in a flat file and can be graphed (separate application).

By default, metrics are saved in current working directory __./results/metrics.txt__



#### Enable capture metrics
Set environment variable *_SITEPRISM_METRICS_ENABLED_*

#### Some optional environment variables
* SITEPRISM_PLUS_DEBUG - prints out info of commands being executed
* SITEPRISM_PLUS_RESULT_DIR - directory where metrics file is saved
* SITEPRISM_PLUS_RESULT_FILE - name of file to save metrics

## Development
This is the initial release, so likely a few bugs. RSpec tests in specs directory. Any contribution/collaboration/help/criticism
is highly welcomed.
* More methods for other use cases
* Currently working on graph app for the metrics 
* More RSpec tests - isn't that always the case
* Obviously, improve this documentation
## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/site_prism_plus.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
# site_prism_plus
