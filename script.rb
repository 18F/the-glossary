class EntryValidator

  @@type_entry = [:term, :acronym]

  attr_reader :context

  def initialize(context)
    @context = context
  end

  # validate_entry Hash -> Result Entry Error
  def validate(data)
    raise ArgumentError if (data.keys.count > 1)
    key = data.keys.first
    values = data.values.first
    case values[:type]
    when "term" then
      validate_term(data)
    when "acronym" then
      validate_acronym(data)
    else
      raise EntryTypeError.new(key)
    end
  end

  def validate_term(term_data)
    key = term_data.keys.first
    values = term_data.values.first
    return true
  end

  def validate_acronym(acronym_data)
    key = acronym_data.keys.first
    values = acronym_data.values.first

    # term defined
    case values[:term].class.to_s
    when "String" then
      check_term_defined(values[:term])
    when "Array" then
      check_term_defined(values[:term])
    when "NilClass" then
      raise MissingTermError.new(key)
    else
      raise MissingTermError.new(key)
    end

    # term in list of terms
    terms = Array(values[:term])
    terms.each do |term|
      unless context[term.to_sym]
        raise TermNotFoundError.new(key, term)
      end
    end

    # extra keys
    keychain = values.keys
    keychain.delete(:term)
    keychain.delete(:type)
    unless keychain.empty?
      raise BadSchemaError.new(keychain)
    end

    return true
  end

  def check_term_defined(term)
    if term.empty?
      MissingTermError.new(key)
    else
      return true
    end
  end

end

# class GlossaryValidator

#   def initialize(path: nil)
#     @path = path || './glossary.yml'
#     @data = YAML.load_file(@path)
#   end

#   def perform
#     @data[:entries]
#   end

# end

class MissingTermError < StandardError
  attr_reader :key, :term

  def initialize(key)
    @key = key
    @term = key.to_s.split('').map { |letter| "#{letter}____ "}.join()
    super(message)
  end

  def message
    <<~ERR
      The acronym \"#{key}\" doesn't define a related term!

      How can I know what your acronym means?

      If you think you added a term, maybe there's a typo somewhere.

      If you haven't added a term, add one like this:

          #{key}:
            type: acronym
            term: #{term}

          ... later on ...

          #{term}:
            type: term
            description: |
              You write out what this term means.
    ERR
  end
end

class TermNotFoundError < StandardError
  attr_reader :key, :missing_term

  def initialize(key, missing_term)
    @key = key
    @missing_term = missing_term
    super(message)
  end

  def message
    <<~ERR
      The acronym \"#{key}\" defines the term \"#{missing_term}\",
      but I cannot find that term anywhere in the glossary.

      How can I know what term to link to?

      Add an entry for #{missing_term}, like:

      #{missing_term}:
        type: term
        description: You write this part.
        cross_references:
          - Terms that are related
          - to this one.
    ERR
  end
end

class TermMissingDescriptionError < StandardError
  def initialize()
  end
  def message
  end
end

class BadSchemaError < StandardError
  attr_reader :extra_keys

  def initialize(extra_keys)
    @extra_keys = extra_keys
    super(message)
  end

  def message
    <<~ERR
      Your acronym defines the following attributes (a.k.a. "keys"):

      #{extra_keys.join(", ")}

      These attributes aren't needed. Please delete them!
    ERR
  end
end

class EntryTypeError < StandardError
  attr_reader :key

  def initialize(key)
    @key = key
    super(message)
  end

  def message
    <<~ERR
      Each entry must have a type of either 'acronym' or 'term'.

      Please add a 'type' key to your entry, with one of those values. Like this:

      #{key}:
        type: acronym # or term
    ERR
  end
end
