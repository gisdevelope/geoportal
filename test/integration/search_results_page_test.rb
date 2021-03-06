require "test_helper"

class SearchResultsPageTest < Capybara::Rails::TestCase

  def setup
  end

  def test_search
    visit '/?q=water'
    assert page.has_content?("Search Results")
  end

  def test_map_clustering
    visit '/?q=water&view=mapview'
    assert page.has_selector?("div.prunecluster.leaflet-marker-icon")
  end

  def test_empty_search
    visit '/?search_field=all_fields&q='
    assert page.assert_selector('div.document', :count => 20)
  end

  def test_facets
    visit '/?q=water'
    assert page.has_selector?("#facets")
    within("#facets") do
      assert page.has_content?("Place")
      assert page.has_content?("Genre")
      assert page.has_content?("Subject")
      assert page.has_content?("Time Period")
      assert page.has_content?("Year")
      assert page.has_content?("Collection")
      assert page.has_content?("Publisher")
      assert page.has_content?("Creator")
      assert page.has_content?("Institution")
      assert page.has_content?("Type")
    end
  end

  def test_getBounds
    visit '/?f%5Btime_period%5D%5B%5D=1600s&per_page=10&q=minnesota&search_field=all_fields'
    assert page.assert_selector('div.document', :count => 10)
  end
end
