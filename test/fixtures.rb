# frozen_string_literal: true

module Fixtures
  #
  # ACRONYMS
  #

  # ACRONYMS : VALID

  def valid_acronym
    { FIDO:
      { type: 'acronym',
        term: 'Federal Interagency Databases Online'
}
}
  end

  def valid_acronym_multi
    { POP:
      { type: 'acronym',
        term:
        ['Period of performance',
         'Procurement Operating Procedure']
}
}
  end

  # ACRONYMS : INVALID

  def invalid_acronym_no_type
    { FIDO:
      { term: 'Federal Interagency Databases Online' }
}
  end

  def invalid_acronym_no_term
    { FIDO:
      { type: 'acronym' }
}
  end

  def invalid_acronym_null_term
    { FIDO:
      { type: 'acronym',
        term: nil
}
}
  end

  def invalid_acronym_extra_keys
    { FIDO:
      { type: 'acronym',
        term: 'Federal Interagency Databases Online',
        longform: 'hey'
}
}
  end

  def invalid_acronym_refers_to_acronym
    { FIDO:
      { type: 'acronym',
        term: 'ODIF'
}
}
  end

  #
  # TERMS
  #

  # TERMS : VALID

  def valid_term
    { "Federal Interagency Databases Online":
      { type: 'term',
        description: 'Fido.gov is an internet location for finding information related to federal interagency databases.',
        longform: 'An even more expanded version of the term.'
}
}
  end

  def valid_term_null_desc
    { "Federal Interagency Databases Online":
      { type: 'term',
        description: nil
}
}
  end

  def valid_term_pop1
    {
      "Period of performance":
        { type: 'term',
          description: 'Description for period of performance'
}
    }
  end

  def valid_term_pop2
    {
      "Procurement Operating Procedure":
        { type: 'term',
          description: 'Description for procurement operating procedure'
}
    }
  end

  def valid_term_no_crossref
    { "Federal Interagency Databases Online":
      { type: 'term',
        description: 'Fido.gov is an internet location for finding information related to federal interagency databases.'
}
}
  end

  def valid_term_matching_crossrefs
    { "Federal Interagency Databases Online":
      { type: 'term',
        description: 'Fido.gov is an internet location for finding information related to federal interagency databases.',
        cross_references:
        ['Period of performance',
         'Procurement Operating Procedure']
}
}
  end

  # TERMS : INVALID

  def invalid_term
    invalid_term_no_desc
  end

  def invalid_term_no_desc
    { "Federal Interagency Databases Online":
      { type: 'term' }
}
  end

  def invalid_term_mismatched_crossrefs
    { "Federal Interagency Databases Online":
      { type: 'term',
        description: 'Fido.gov is an internet location for finding information related to federal interagency databases.',
        cross_references:
        [
          'Period of performance',
          'Not a match'
        ]
}
}
  end

  def invalid_term_crossrefs_acronym
    { "A term in the glossary":
      { type: 'term',
        description: "This is a term that appears in the glossary and its description written here so people know it's just a term.",
        cross_references:
        [
          'ACRO'
        ]
      }
    }
  end

  def invalid_term_extra_keys
    { "Federal Interagency Databases Online":
      { type: 'term',
        description: 'Fido.gov is an internet location for finding information related to federal interagency databases.',
        has_extra_key: 'Yes'
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
    valid_term_pop1.merge(valid_term_pop2)
  end

  def context_matching_crossrefs
    context_for_valid_term_multi
  end

  def context_for_invalid_acronym_refers_to_acronym
    { ODIF:
      { type: 'acronym',
        term: 'Online Database of Interagency Federation'
}
}
  end

  def context_for_term_cross_references_acronym
    { ACRO:
      { type: 'acronym',
        term: 'Letters That Stand For Words'
}
}
  end
end
