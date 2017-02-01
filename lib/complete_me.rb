require 'pry'

class CompleteMe
  attr_accessor :dictionary, :count

  def initialize
    @dictionary = Node.new("")
    @count = 0
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
    starting_node = @dictionary.find_starting_node(entry)
    starting_node.suggest(entry)
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

  def find_starting_letter(key_letter, search_node)
    search_node.children[key_letter]
  end

  def find_starting_node(entry)
    starting_node = self
    entry.length.times do |index|
      starting_node = find_starting_letter(entry[index], starting_node)
    end
    return starting_node
  end

  def suggest(entry, suggestion=entry)
    #binding.pry
    children.keys.each do |letter|
      binding.pry
      self.evaluate_suggestion(letter, suggestion)
      binding.pry
    end

  end

  new_node = def evaluate_suggestion(letter, suggestion)
    binding.pry
    unless children[letter].word
      suggestion += children[letter].value
      children[letter].suggest(children[letter].children.keys[0], suggestion)
    else
      @final_suggestion << suggestion + children[letter].value
    end
    return children[letter]
  end

end
