# -*- encoding: utf-8 -*-
module GvoiceRuby
  class User
    # User is not a struct because we require email and password attributes
    attr_accessor :email, :password
    
    def initialize(email, password)
     @email    = email
     @password = password
    end
  end
end