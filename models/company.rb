require_relative 'user'

# This class represents the company entity
class Company
    attr_reader :id, :name, :email_status, :top_up, :emailed_users, :not_emailed_users
  
    # Constructor to initialize Company's attributes
    #
    # @param [Integer] id The company ID
    # @param [String] name The company name
    # @param [Boolean] email_status Whether the company is set to email users
    # @param [Integer] top_up The amount of tokens to top up for each user
    def initialize(id, name, email_status, top_up)
      @id = id
      @name = name
      @email_status = email_status
      @top_up = top_up
      @emailed_users = []
      @not_emailed_users = []
    end
  
    # Add a user to either the emailed_users and not_emailed_users list based on the
    # user email_status and the company's email_status
    #
    # @param [User] user The user object to be added
    def add_user(user)
      if user.email_status && @email_status
        @emailed_users << user
      else
        @not_emailed_users << user
      end
    end
  
    # Sort both emailed_users and not_emailed_users arrays by the users last name
    def sort_users
      @emailed_users.sort_by!(&:last_name)
      @not_emailed_users.sort_by!(&:last_name)
    end
  
    # Calculate the total top-ups for this company
    #
    # @return [Integer] The total token top-ups
    def total_top_ups
      (@emailed_users.size + @not_emailed_users.size) * @top_up
    end
  end