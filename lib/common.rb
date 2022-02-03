# frozen_string_literal: true

# Method(s) common to many modules
module Common
  # Thanks https://avdi.codes/recursively-symbolize-keys/
  def symbolize_keys(hash)
    hash.each_with_object({}) do |(key, value), result|
      new_key = key.is_a?(String) ? key.to_sym : key
      new_value = value.is_a?(Hash) ? symbolize_keys(value) : value
      result[new_key] = new_value
    end
  end
end
