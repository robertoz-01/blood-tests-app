# frozen_string_literal: true

# This class represents an entry coming from the user interface
class UserEntry
  include ActiveModel::API
  attr_accessor :identifier, :name, :value, :unit, :reference_lower, :reference_upper, :message
end
