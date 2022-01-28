require 'minitest/autorun'
require './lib/markdownify'

describe Markdownify do
  describe "with a valid glossary.yml" do
    it "renders markdown" do
      subject = Markdownify.new('./test/test_glossary.yml')
      assert_equal valid_markdown, subject._perform
    end
  end
end

def glossary_data
  entries = [ valid_acronym,
              valid_acronym_multi,
              valid_term_matching_crossrefs,
              valid_term_pop_1,
              valid_term_pop_2,
              ].inject(&:merge)
  { entries: entries }.to_yaml
end

def valid_markdown
  <<~MARKDOWN
    ### Acronyms & Initialisms

    <a name=\"acronym-FIDO\"></a>[FIDO](#federal-interagency-databases-online) | <a name=\"acronym-POP\"></a>POP [(1)](#period-of-performance) [(2)](#procurement-operating-procedure)

    ### Terms & Definitions

    **<a name=\"federal-interagency-databases-online\"></a>[Federal Interagency Databases Online](#federal-interagency-databases-online)** (FIDO) \\
    Fido.gov is an internet location for finding information related to federal interagency databases.

    Cross-references:

      - [Period of performance](#period-of-performance)
      - [Procurement Operating Procedure](#procurement-operating-procedure)

    **<a name=\"period-of-performance\"></a>[Period of performance](#period-of-performance)** (POP) \\
    Description for period of performance

    _Not the definition you were looking for?_ [Back to POP](#acronym-POP)

    **<a name=\"procurement-operating-procedure\"></a>[Procurement Operating Procedure](#procurement-operating-procedure)** (POP) \\
    Description for procurement operating procedure

    _Not the definition you were looking for?_ [Back to POP](#acronym-POP)
  MARKDOWN
end
