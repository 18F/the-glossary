require 'minitest/autorun'
require './lib/validate'
require './lib/markdownify'

describe EntryValidator do
  describe "with a valid glossary.yml" do
    it "renders markdown" do
      puts "----> #{Dir.pwd}"
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

describe EntryValidator do
  describe "with a malformed entry" do
    it "is errors" do
      subject = EntryValidator.new({})
      assert_raises (ArgumentError) { subject.validate({a: 1, b: 2}) }
    end
  end

  describe "term" do
    describe "with a valid term" do
      it "is valid" do
        subject = EntryValidator.new({})
        assert_equal true, subject.validate(valid_term)
      end
    end
    describe "without a description" do
      it "is invalid" do
        subject = EntryValidator.new({})
        assert_raises (TermMissingDescriptionError) { subject.validate(invalid_term_no_desc) }
      end
    end
    describe "with extra keys" do
      it "is invalid" do
        subject = EntryValidator.new({})
        assert_raises (BadSchemaError) { subject.validate(invalid_term_extra_keys) }
      end
    end
    describe "without cross-references" do
      it "is valid" do
        subject = EntryValidator.new({})
        assert_equal true, subject.validate(valid_term_no_crossref)
      end
    end
    describe "with cross-references" do
      describe "that all match" do
        it "is valid" do
          subject = EntryValidator.new(context_matching_crossrefs)
          assert_equal true, subject.validate(valid_term_matching_crossrefs)
        end
      end
      describe "that don't match" do
        it "is invalid" do
          subject = EntryValidator.new(context_matching_crossrefs)
          assert_raises (TermNotFoundError) { subject.validate(invalid_term_mismatched_crossrefs) }
        end
      end
    end
    describe "with an explicitly null description" do
      it "is valid" do
        subject = EntryValidator.new({})
        assert_equal true, subject.validate(valid_term_null_desc)
      end
    end
  end

  describe "acronym" do
    describe "without a type" do
      it "is invalid" do
        subject = EntryValidator.new({})
        assert_raises (EntryTypeError) { subject.validate(invalid_acronym_no_type) }
      end
    end
    describe "without a term" do
      it "is invalid" do
        subject = EntryValidator.new({})
        assert_raises (MissingTermError) { subject.validate(invalid_acronym_no_term) }
      end
    end
    describe "with an explicitly null term" do
      it "is invalid" do
        subject = EntryValidator.new({})
        assert_raises (MissingTermError) { subject.validate(invalid_acronym_null_term) }
      end
    end
    describe "with any other keys" do
      it "is invalid" do
        subject = EntryValidator.new(valid_term)
        assert_raises (BadSchemaError) { subject.validate(invalid_acronym_extra_keys) }
      end
    end

    describe "valid" do
      describe "referring to one term" do
        describe "matching a valid term" do
          it "is valid" do
            subject = EntryValidator.new(context_for_valid_term)
            assert_equal true, subject.validate(valid_acronym)
          end
        end
        describe "matching an invalid term" do
          it "is valid" do
            subject = EntryValidator.new(context_for_invalid_term)
            assert_equal true, subject.validate(valid_acronym)
          end
        end
        describe "that does not match" do
          it "is invalid" do
            subject = EntryValidator.new({})
            assert_raises (TermNotFoundError) { subject.validate(valid_acronym) }
          end
        end
      end
    end

    describe "referring to another acronym" do
      it "is invalid" do
        subject = EntryValidator.new(context_for_invalid_acronym_refers_to_acronym)
        assert_raises (AcronymReferenceError) { subject.validate(invalid_acronym_refers_to_acronym) }
      end
    end

    describe "referring to multiple terms" do
      describe "which all match" do
        it "is valid" do
          subject = EntryValidator.new(context_for_valid_term_multi)
          assert_equal true, subject.validate(valid_acronym_multi)
        end
      end
      describe "one of which doesn't match a term" do
        it "is invalid" do
          subject = EntryValidator.new(valid_term_pop_1)
          assert_raises (TermNotFoundError) { subject.validate(valid_acronym_multi) }
        end
      end
    end
  end
end

#
# ACRONYMS
#

# ACRONYMS : VALID

def valid_acronym
  { FIDO:
    { type: "acronym",
      term: "Federal Interagency Databases Online"
    }
  }
end

def valid_acronym_multi
  { POP:
    { type: "acronym",
      term:
      [ "Period of performance",
        "Procurement Operating Procedure"
      ]
    }
  }
end

# ACRONYMS : INVALID

def invalid_acronym_no_type
  { FIDO:
    { term: "Federal Interagency Databases Online"
    }
  }
end

def invalid_acronym_no_term
  { FIDO:
    { type: "acronym",
    }
  }
end

def invalid_acronym_null_term
  { FIDO:
    { type: "acronym",
      term: nil
    }
  }
end

def invalid_acronym_extra_keys
  { FIDO:
    { type: "acronym",
      term: "Federal Interagency Databases Online",
      longform: "hey"
    }
  }
end

def invalid_acronym_refers_to_acronym
  { FIDO:
    { type: "acronym",
      term: "ODIF"
    }
  }
end

#
# TERMS
#

# TERMS : VALID

def valid_term
  { "Federal Interagency Databases Online":
    { type: "term",
      description: "Fido.gov is an internet location for finding information related to federal interagency databases.",
      longform: "An even more expanded version of the term."
    }
  }
end

def valid_term_null_desc
  { "Federal Interagency Databases Online":
    { type: "term",
      description: nil
    }
  }
end

def valid_term_pop_1
  {
    "Period of performance":
      { type: "term",
        description: "Description for period of performance"
      }
  }
end

def valid_term_pop_2
  {
    "Procurement Operating Procedure":
      { type: "term",
        description: "Description for procurement operating procedure"
      }
  }
end

def valid_term_no_crossref
  { "Federal Interagency Databases Online":
    { type: "term",
      description: "Fido.gov is an internet location for finding information related to federal interagency databases."
    }
  }
end

def valid_term_matching_crossrefs
  { "Federal Interagency Databases Online":
    { type: "term",
      description: "Fido.gov is an internet location for finding information related to federal interagency databases.",
      cross_references:
      [ "Period of performance",
        "Procurement Operating Procedure"
      ]
    }
  }
end

# TERMS : INVALID

def invalid_term
  invalid_term_no_desc
end

def invalid_term_no_desc
  { "Federal Interagency Databases Online":
    { type: "term"
    }
  }
end

def invalid_term_mismatched_crossrefs
  { "Federal Interagency Databases Online":
    { type: "term",
      description: "Fido.gov is an internet location for finding information related to federal interagency databases.",
      cross_references:
      [
        "Period of performance",
        "Not a match"
      ]
    }
  }
end

def invalid_term_extra_keys
  { "Federal Interagency Databases Online":
    { type: "term",
      description: "Fido.gov is an internet location for finding information related to federal interagency databases.",
      has_extra_key: "Yes"
    }
  }
end


#
# CONTEXTS
#

def context_for_valid_term
  valid_term
end

def context_for_invalid_term
  invalid_term
end

def context_for_valid_term_multi
  valid_term_pop_1.merge(valid_term_pop_2)
end

def context_matching_crossrefs
  context_for_valid_term_multi
end

def context_for_invalid_acronym_refers_to_acronym
  { ODIF:
    { type: "acronym",
      term: "Online Database of Interagency Federation"
    }
  }
end
