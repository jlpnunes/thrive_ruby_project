# This class represents the user entity
class User
    attr_reader :first_name, :last_name, :email, :tokens, :email_status, 
    :active_status, :company_id, :new_balance
  
    # Constructor to initialize User's attributes
    #
    # @param [String] first_name The user's first name
    # @param [String] last_name The user's last name
    # @param [String] email The user's email address
    # @param [Integer] tokens The user's token balance
    # @param [Boolean] email_status Whether the user is set to be emailed
    # @param [Boolean] active_status Whether the user is active
    # @param [Integer] company_id The company ID to which the user belongs
    def initialize(first_name, last_name, email, tokens, email_status,
       active_status, company_id)
      @first_name = first_name
      @last_name = last_name
      @email = email
      @tokens = tokens
      @email_status = email_status
      @active_status = active_status
      @company_id = company_id
      @new_balance = 0
    end
  
    # Calculate the new token balance
    #
    # @param [Integer] top_up The amount of tokens to add
    def update_tokens(top_up)
      @new_balance = @tokens + top_up
    end
  
    # Return the user's full name
    #
    # @return [String] The user's "last_name, first_name" format
    def full_name
      "#{@last_name}, #{@first_name}"
    end
  end