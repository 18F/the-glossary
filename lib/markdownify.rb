# frozen_string_literal: true

# Thanks https://avdi.codes/recursively-symbolize-keys/
require 'yaml'
require './lib/common'
require './lib/validate'

# Turn a validated glossary into a linked Markdown file
class Markdownify
  include Common

  attr_reader :data, :path, :output

  def initialize(path = nil, outpath = nil)
    @path = path || './glossary.yml'
    @output = outpath || './glossary.md'
    @data = sort_data(
      symbolize_keys(
        YAML.load_file(@path)
      )
    )
  end

  def perform
    File.open(output, 'w') { |file| file << _perform }
    puts "\nSuccess! Check out your file at #{output}"
  end

  def _perform
    before_perform
    str = ''
    str += "### Acronyms & Initialisms\n\n"
    str += acronym_content
    str += "\n\n"
    str += "### Terms & Definitions\n\n"
    str += definition_content.join("\n")
    str
  end

  def acronym_content
    str = ''
    str += "| | |\n|-|-|\n" # table header
    build_tags_by_letter.sort.map do |letter, tags|
      str += "| #{letter} | "
      str += "#{tags.join(' &bull; ')} |"
      str += "\n"
    end
    str
  end

  def build_tags_by_letter
    results = Hash.new { |h, k| h[k] = [] }
    data[:acronyms].sort.each do |key, values|
      tag = tag_for_acronym(key, values)
      next if tag.nil?

      results[key.to_s.chars.first.upcase] << tag
    end
    results
  end

  def tag_for_acronym(key, values)
    case Array(values[:term]).count
    when 0
      nil
    when 1
      tag_for_single_term(key, values)
    else
      tag_for_multiple_terms(key, values)
    end.strip
  end

  def tag_for_single_term(key, values)
    <<~TAG
      <a name="acronym-#{key}"></a>[#{key}](#{goto values[:term]})
    TAG
  end

  def tag_for_multiple_terms(key, values)
    term_links = values[:term].map.with_index do |term, i|
      "[(#{i + 1})](#{goto term})"
    end.join(' ')
    <<~TAG
      <a name="acronym-#{key}"></a>#{key} #{term_links}
    TAG
  end

  def definition_content
    data[:terms]
      .sort_by { |k, _v| k.to_s.downcase }
      .map { |key, values| build_definition(key, values) }
  end

  def build_definition(key, values)
    str = ''
    str += "**#{anchor(key)}#{self_link(key)}**"
    str += (acronym?(key) ? " (#{acronym_for(key).first}) \\\n" : " \\\n")
    str += description_content(values)
    if overloaded_acronym?(key)
      acro = acronym_for(key).first
      str += "\n_Not the definition you were looking for?_ [Back to #{acro}](#acronym-#{acro})\n"
    end
    if values[:cross_references]
      str += "\nCross-references:\n\n"
      Array(values[:cross_references]).each { |crossref| str += crossref_link(crossref) }
    end
    str
  end

  def description_content(values)
    case values[:description]
    when nil then "_No definition provided._\n"
    else "#{values[:description]}\n"
    end
  end

  def overloaded_acronym?(key)
    if acronym?(key)
      _, values = acronym_for(key)
      Array(values[:term]).count > 1
    else
      false
    end
  end

  def acronym?(key)
    maybe_results = acronym_lookup(key)
    case maybe_results.count
    when 0
      false
    when 1
      true
    else
      true
      # raise RuntimeError, "#{key} has more than 1 acronym: #{maybe_results.inspect}.\n\nHow is this possible?"
    end
  end

  def acronym_for(key)
    maybe_results = acronym_lookup(key)
    case maybe_results.count
    when 0
      raise "Shouldn't be calling acronym_for unless acronym? has already been run."
    when 1
      maybe_results.first
    else
      maybe_results.first # Ignore special cases. @todo fix this
      # raise RuntimeError, "#{key} has more than 1 acronym: #{maybe_results.join(", ")}.\n\nHow is this possible?"
    end
  end

  def acronym_lookup(key)
    key_str = key.to_s
    data[:acronyms].select do |_key, values|
      next unless values[:term]

      Array(values[:term]).detect { |t| t == key_str }
    end.compact
  end

  def crossref_link(crossref)
    crossref_data = data[:terms][crossref.to_sym]
    raise "No data for crossref: #{crossref}" unless crossref_data

    "  - [#{crossref}](#{goto crossref})\n"
  end

  def goto(key)
    "##{slug(key)}"
  end

  def self_link(key)
    "[#{key}](#{goto key})"
  end

  def anchor(key)
    "<a name=\"#{slug(key)}\"></a>"
  end

  def slug(key)
    key.to_s.downcase.gsub(/\s+/, '-')
  end

  private

  def before_perform
    GlossaryValidator.new(path: path).perform
  end

  def sort_data(data)
    acronyms = {}
    terms = {}
    data[:entries].each do |entry|
      key, values = entry
      case values[:type]
      when 'acronym'
        acronyms[key] = values
      when 'term'
        terms[key] = values
      end
    end
    { acronyms: acronyms, terms: terms }
  end
end
