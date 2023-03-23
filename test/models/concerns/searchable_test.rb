require 'test_helper'

class SearchableTest < ActiveSupport::TestCase
  setup do
    @term = 'search-term'
    @mock = Minitest::Mock.new
  end

  should 'build case insensitive condition by default' do
    @mock.expect :call, nil, ['name ILIKE :term', { term: "%#{@term}%" }]

    SearchCaseInsensitive.stub(:where, @mock) do
      SearchCaseInsensitive.search(@term)
    end

    assert_mock @mock
  end

  should 'build case sensitive condition' do
    @mock.expect :call, nil, ['name LIKE :term', { term: "%#{@term}%" }]

    SearchCaseSensitive.stub(:where, @mock) do
      SearchCaseSensitive.search(@term)
    end

    assert_mock @mock
  end

  should 'build condition with two params' do
    @mock.expect :call, nil, ['name ILIKE :term OR initials LIKE :term', { term: "%#{@term}%" }]

    SearchWithParams.stub(:where, @mock) do
      SearchWithParams.search(@term)
    end

    assert_mock @mock
  end
end

class SearchCaseInsensitive
  include Searchable

  search_by :name

  def self.where(*args)
    puts args
  end
end

class SearchCaseSensitive
  include Searchable

  search_by name: { case_sensitive: true }

  def self.where(*args); end
end

class SearchWithParams
  include Searchable

  search_by :name, initials: { case_sensitive: true }

  def self.where(*args); end
end
