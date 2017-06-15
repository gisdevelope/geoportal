require "test_helper"

class SearchResultsPageTest < Capybara::Rails::TestCase

  def setup
    # Remote testing the show page features
    Capybara.app_host = 'https://geodev.btaa.org'
  end

  def test_search
    visit '/?q=water'
    assert page.has_content?("Search Results")
  end

  def test_empty_search
    visit '/?search_field=all_fields&q='
    assert page.assert_selector('div.document', :count => 20)
  end

  def test_facets
    visit '/?q=water'
    assert page.has_selector?("#facets")
    assert page.assert_selector('div.facet_limit', :count => 11)
    assert page.has_content?("Institution")
    assert page.has_content?("Subject")
    assert page.has_content?("Author")
    assert page.has_content?("Place")
    assert page.has_content?("Year")
    assert page.has_content?("Time Period")
    assert page.has_content?("Access")
    assert page.has_content?("Data type")
    assert page.has_content?("Format")
  end

  def test_getBounds
    js do
      visit '/?f%5Btime_period%5D%5B%5D=1600s&per_page=10&q=asia&search_field=all_fields'
      assert page.assert_selector('div.document', :count => 10)
    end
  end
end
