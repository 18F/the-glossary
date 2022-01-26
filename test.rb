require 'minitest/autorun'
require './script'

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

    describe "with multiple terms" do
      it "is valid"
    end

    describe "with a valid acronym" do
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
            # assert_raises (TermNotFoundError) { subject.valid? }
          end
        end
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

#
# TERMS
#

# TERMS : VALID

def valid_term
  { "Federal Interagency Databases Online":
    { type: "term",
      description: "Fido.gov is an internet location for finding information related to federal interagency databases."
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
