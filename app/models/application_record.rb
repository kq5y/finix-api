# Base class for all models in the application
class ApplicationRecord < ActiveRecord::Base
  include Discard::Model
  default_scope -> { kept }

  primary_abstract_class
end
