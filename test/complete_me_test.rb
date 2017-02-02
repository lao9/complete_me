require 'simplecov'
SimpleCov.start do
  add_filter "/test/"
end
require "minitest"
require "minitest/emoji"
require "minitest/autorun"
require "../complete_me/lib/complete_me"
require 'pry'

class CompleteMeTest < Minitest::Test
  attr_reader :cm
  def setup
    @cm = CompleteMe.new
  end

  def test_starting_count
    assert_equal 0, cm.count
  end

  def test_inserts_single_word
    cm.insert("pizza")
    assert_equal 1, cm.count
  end

  def test_inserts_multiple_words
    cm.populate("pizza\ndog\ncat")
    assert_equal 3, cm.count
  end

  def test_counts_inserted_words
    insert_words(["pizza", "aardvark", "zombies", "a", "xylophones"])
    assert_equal 5, cm.count
  end

  def test_suggests_off_of_small_dataset
    insert_words(["pizza", "aardvark", "zombies", "a", "xylophones"])
    assert_equal ["pizza"], cm.suggest("p")
    assert_equal ["pizza"], cm.suggest("piz")
    assert_equal ["zombies"], cm.suggest("zo")
    assert_equal ["a", "aardvark"], cm.suggest("a").sort
    assert_equal ["aardvark"], cm.suggest("aa")
  end


  def test_inserts_medium_dataset
    cm.populate(medium_word_list)
    assert_equal medium_word_list.split("\n").count, cm.count
  end

  def test_suggests_off_of_medium_dataset
    cm.populate(medium_word_list)
    assert_equal ["williwaw", "wizardly"], cm.suggest("wi").sort
  end

  def test_selects_off_of_medium_dataset
    cm.populate(medium_word_list)
    cm.select("wi", "wizardly")
    assert_equal ["wizardly", "williwaw"], cm.suggest("wi")
  end

  def test_works_with_large_dataset
    cm.populate(large_word_list)
    assert_equal ["doggerel", "doggereler", "doggerelism", "doggerelist", "doggerelize", "doggerelizer"], cm.suggest("doggerel").sort
    cm.select("doggerel", "doggerelist")
    assert_equal "doggerelist", cm.suggest("doggerel").first
  end

  def test_substring_specific_selection_tracking
    cm.populate(large_word_list)
    cm.select("piz", "pizzeria")
    cm.select("piz", "pizzeria")
    cm.select("piz", "pizzeria")
    cm.select("pi", "pizza")
    cm.select("pi", "pizza")
    cm.select("pi", "pizzicato")
    assert_equal "pizzeria", cm.suggest("piz").first
    assert_equal ["pizza", "pizzicato"], cm.suggest("pi").take(2)
  end

  def test_selects_other_trees
    insert_words(["wizardly", "williwaw", "wizards"])
    assert_equal ["williwaw", "wizardly", "wizards"], cm.suggest("wi").sort
  end

  def test_denver_extension
    cm.populate(denver_address_list)
    assert_equal 296879, cm.count
    assert_equal ["4400 N Mariposa Way", "4400 N Madison St", "4400 N Malaya St"], cm.suggest("4400 N M")
    assert_equal ["1 N Clarkson St", "1 N Crestmoor Dr", "1 N Corona St"], cm.suggest("1 N C")
    cm.select("1 N C", "1 N Corona St")
    cm.select("1 N C", "1 N Corona St")
    cm.select("1 N C", "1 N Crestmoor Dr")
    assert_equal ["1 N Corona St", "1 N Crestmoor Dr", "1 N Clarkson St"], cm.suggest("1 N C")
  end

  def insert_words(words)
    cm.populate(words.join("\n"))
  end

  def medium_word_list
    File.read("./test/medium.txt")
  end

  def large_word_list
    File.read("/usr/share/dict/words")
  end

  def denver_address_list
    File.read("./test/denver_addresses.txt")
  end

end
