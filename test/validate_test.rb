require './test/test_helper'
require './lib/validate'
require './test/fixtures'

include Fixtures

describe GlossaryValidator do
  describe "with a valid glossary" do
    it "raises no errors" do
      subject = GlossaryValidator.new(path: './test/test_glossary.yml')
      assert subject.perform
    end
  end

  describe "with a glossary containing duplicate entries" do
    it "raises an error" do
      subject = GlossaryValidator.new(path: './test/test_glossary_dupe.yml')
      assert_raises (DuplicateKeyError) { subject.perform }
    end
  end
end

describe EntryValidator do
  describe "with a malformed entry" do
    it "errors" do
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
