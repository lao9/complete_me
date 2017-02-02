require 'pry'

class CompleteMe
  attr_accessor :dictionary, :count

  def initialize
    @dictionary = Node.new("")
    @count = 0
    @selection_hash = {}
  end

  def insert(word)
    @dictionary.insert(word)
    @count += 1
  end

  def populate(entry)
    entry.split("\n").each do |word|
      @dictionary.insert(word)
      @count += 1
    end
  end

  def suggest(entry)
    collection = @dictionary.suggest(entry)

    output = bubble_sort(collection, entry)

    return output
    #binding.pry

  end

  def bubble_sort(collection, entry)

    sorted = [collection.shift]

    counter = 0

    until collection[0] == nil
      #binding.pry

      if @selection_hash.empty?
        item_of_interest_1 = 0
      elsif @selection_hash[entry][collection[0]] == nil
        item_of_interest_1 = 0
      else
        item_of_interest_1 = @selection_hash[entry][collection[0]]
      end

      if @selection_hash.empty?
        item_of_interest_2 = 0
      elsif @selection_hash[entry][sorted[counter]] == nil
        item_of_interest_2 = 0
      else
        item_of_interest_2 = @selection_hash[entry][sorted[counter]]
      end

      if item_of_interest_2 < item_of_interest_1
        sorted.insert(counter, collection.shift)
        counter = 0
      else
        counter += 1
      end

      if counter >= sorted.count
        sorted.insert(counter, collection.shift)
        counter = 0
      end

    end

    return sorted

  end

  def select(entry, selection)
    if @selection_hash[entry] != nil #if the hash with key of "wi" does exist
      if @selection_hash[entry][selection] != nil #if the hash with key of "willawaw" does exists
        @selection_hash[entry][selection] += 1
      else #if the hash with the key of "willawaw" does not exist
        @selection_hash[entry][selection] = 1
      end
    else # if the hash with key of "wi" does not exist
      @selection_hash[entry] = {selection => 1} # add a hash element to the hash key with a counter integer
    end

  end

end


class Node
  attr_accessor :value, :children, :word, :parent
  def initialize(value)
    @value = value
    @children = {}
    @word = false
    @weight = 0
    @parent = parent
    @final_suggestion = []
  end

  def insert(word)
    # separate the first letter of the word from the rest of the word
    first_letter = word[0]
    rest_of_word = word[1..-1]

    # with every insertion, we need to go through the word letter by letter
    # so first we check if our current node's
    # children hash has a key of the first letter
    unless children[first_letter]
      # if it does not, we create a new node and
      # enter it as a value in our children has
      # with the first letter as the key
      children[first_letter] = Node.new(first_letter)
    end

    # now we check how much more of the word we have left
    if rest_of_word.length.zero?
      # if we don't have any word left,
      # we set our current node's
      # boolean for word completion to true
      children[first_letter].word = true
    else
      # otherwise, we recurse through the insert function with the rest of the word
      children[first_letter].insert(rest_of_word)
    end

  end

  def suggest(entry)

    # find starting node
    node = self.find_starting_node(entry)

    # initialize suggetion
    suggestion = entry
    sugg_arr = []
    start_node = node

    # test that the entry isn't also a word
    sugg_arr = node.test_if_node_is_word(sugg_arr, suggestion)

    #binding.pry

    sugg_arr = node.at_key_branches(node, suggestion, sugg_arr)

    # return our suggested array

    return sugg_arr
    #binding.pry
  end

  sugg_arr = def at_key_branches(start_node, entry, sugg_arr)
    key_arr = start_node.children.keys
    key_arr.each do |key|
      # we re-initialize the suggestion and start_node
      suggestion = entry
      node = start_node
      # then we run through the keys for the node and shovel any valid suggestions
      # into our suggested array
      sugg_arr = node.for_each_key(key, suggestion, node, sugg_arr)
      #binding.pry
    end
    return sugg_arr
    #binding.pry
  end

  def for_each_key(key, suggestion, node, sugg_arr)
    # while our key (a letter, the child of our parent node) is valid
    while key!=nil
      # generate a new suggestion by adding the new key to that suggestion
      suggestion = node.suggester_rolodex(suggestion, key)
      # ensure that our key is not reset to nil
      if node.node_rolodex(key).nil?
        node = node
      else
        # otherwise move into our new suggestion's node
        node = node.node_rolodex(key)
      end
      # check to see if the new suggestion is valid
      # if so move into the suggestion array
      sugg_arr = node.test_if_node_is_word(sugg_arr, suggestion)
      # make the new key the next child
      #binding.pry
      # mini_word_storage
      if node.children.keys.length < 2
        key = node.children.keys[0]
      else
        #binding.pry
        node.at_key_branches(node, suggestion, sugg_arr)
        key = nil
      end
      #binding.pry #sugg_arr is correct
    end
    return sugg_arr
    #binding.pry
  end

  sugg_arr = def test_if_node_is_word(array, entry)
    if word
      array << entry
    end
    return array
  end

  def find_starting_node(entry)
    counter = 0
    letter = entry[counter]
    node = self
    while letter != nil
      # single line if statement, block this guy from creating a nil
      if node.node_rolodex(letter).nil?
        node = node
      else
        node = node.node_rolodex(letter)
      end
      # binding.pry
      counter += 1
      letter = entry[counter]
    end
    node
  end

  def node_rolodex(letter)
    # changes our starting node to the node with that the input letter
    starting_node = children[letter]
  end

  def suggester_rolodex(entry, letter)
    # otherwise, we add the inputted letter key to our suggestion
    suggestion = entry + letter
  end

end
