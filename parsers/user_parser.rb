require_relative 'abstract_parser'

# Concrete class for handling User JSON data
class UserParser < AbstractParser
    USER_JSON_FIELDS = ['first_name', 'last_name', 'email', 'tokens', 'email_status', 'active_status', 'company_id']
  
    # Override the abstract method to create and validate user objects
    #
    # @param [Array<Hash>] users_data Array of raw user data
    # @return [Array<User>] Array of valid User objects
    def self.initialize_objects(users_data)
      users_data.map do |user_data|
        if USER_JSON_FIELDS.all? { |field| user_data.key?(field) }
          User.new(
            user_data['first_name'],
            user_data['last_name'],
            user_data['email'],
            user_data['tokens'],
            user_data['email_status'],
            user_data['active_status'],
            user_data['company_id']
          )
        end
      end.compact # Remove nil values (invalid data)
    end
  end