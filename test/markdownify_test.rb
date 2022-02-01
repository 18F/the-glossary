require './test/test_helper'
require './lib/markdownify'

describe Markdownify do
  describe "with a valid glossary.yml" do
    it "renders markdown" do
      subject = Markdownify.new('./test/test_glossary.yml')
      assert_equal valid_markdown, subject._perform, highlight: true
    end
  end
end

def valid_markdown
  <<~MARKDOWN
    ### Acronyms & Initialisms

    | | |
    |-|-|
    | F | <a name=\"acronym-FEMA\"></a>[FEMA](#federal-emergency-management-agency) &bull; <a name=\"acronym-FIDO\"></a>[FIDO](#federal-interagency-databases-online) |
    | P | <a name=\"acronym-POP\"></a>POP [(1)](#period-of-performance) [(2)](#procurement-operating-procedure) |


    ### Terms & Definitions

    **<a name=\"federal-emergency-management-agency\"></a>[Federal Emergency Management Agency](#federal-emergency-management-agency)** (FEMA) \\
    _No definition provided._

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
