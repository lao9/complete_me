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
  end

  def bubble_sort(collection, entry)
    sorted = [collection.shift]
    counter = 0

    until collection[0] == nil

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
    if @selection_hash[entry] != nil # if the hash with key (user entry) does exist
      if @selection_hash[entry][selection] != nil # if the hash with key of user's selection does exist
        @selection_hash[entry][selection] += 1
      else # if the hash with key of user's selection does NOT exist
        @selection_hash[entry][selection] = 1 # initialize nested hash value with count = 1
      end
    else # if the hash with key (user entry) does NOT exist
      @selection_hash[entry] = {selection => 1} # initialize nested hash with key of selection and value with count = 1
    end
  end

end


class Node
  attr_accessor :value, :children, :word, :parent
  def initialize(value)
    @value = value
    @children = {}
    @word = false
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
    sugg_arr = [] # "sugar" = suggestion array ;)
    start_node = node
    # test that the entry isn't also a word
    sugg_arr = node.test_if_node_is_word(sugg_arr, suggestion)
    # next evaluate how many children we have so we can iterate through them
    sugg_arr = node.children_iterator(node, suggestion, sugg_arr)
    # return our suggested array
    return sugg_arr
  end

  def children_iterator(start_node, entry, sugg_arr)
    key_arr = start_node.children.keys # create an array of all children
    key_arr.each do |key|
      # we re-initialize the suggestion and start_node
      suggestion = entry
      node = start_node
      # then we run each child into the suggester builder
      sugg_arr = node.suggester_builder(key, suggestion, node, sugg_arr)
    end
    # return our suggested array
    return sugg_arr
  end

  def suggester_builder(key, suggestion, node, sugg_arr)
    # while our children (key) exist
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
      # check to see current suggestion is a word and shovel into sugar
      sugg_arr = node.test_if_node_is_word(sugg_arr, suggestion)
      # determine which child is next
      if node.children.keys.length < 2
        # if there's only one child (or none), we set that child to our current node
        key = node.children.keys[0]
        # if key = nil, the sugggester stops because the current node has ended
      else
        # if there is more than one child, we must go back to our children_iterator to pick which one
        node.children_iterator(node, suggestion, sugg_arr)
        key = nil
        # once that is complete, we terminate the suggester for this branch
      end
    end
    return sugg_arr
    # return our suggested array
  end

  def test_if_node_is_word(sugg_arr, entry)
    if word # if the current word is valid
      sugg_arr << entry # shovel!
    end
    return sugg_arr
  end

  def find_starting_node(entry)
    # rifle through our dictionary so we can start where the user wants us to
    counter = 0
    letter = entry[counter]
    node = self
    while letter != nil
      # check to make sure node is not nil
      if node.node_rolodex(letter).nil?
        node = node
      else
        # set node to the next child of our user input
        node = node.node_rolodex(letter)
      end
      counter += 1
      letter = entry[counter]
    end
    return node
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
