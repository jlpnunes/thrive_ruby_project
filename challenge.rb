##
# This script reads user and company data from JSON files, assign
# users to companies, update tokens, and write the results to a file.
#

require 'json'

# Constants that store path of the files
USERS_FILE = 'users.json'
COMPANIES_FILE = 'companies.json'
OUTPUT_FILE = 'output.txt'

# Constants that stores the fields required to validate raw JSON data
COMPANY_JSON_FIELDS = ['id', 'name', 'email_status', 'top_up']
USER_JSON_FIELDS = ['first_name', 'last_name', 'email', 'tokens', 'email_status', 'active_status', 'company_id']

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

# Loads and retrieves JSON data from a file
#
# @param [String] file_path The path of the file
# @return [Array<Hash>] Array of hashes from JSON file
def load_json_data(file_path)
  file = File.read(file_path)
  JSON.parse(file)
rescue Errno::ENOENT
  puts "Error: File #{file_path} doesn't exist"
  []
rescue JSON::ParserError => e
  puts "Error: Parsing JSON file: #{e.message}"
  []
rescue => e
  puts "Error: While reading file: #{e.message}"
end

# Create an array of company object from the given raw data
#
# @param [Array<Hash>] companies_data An array of raw company data from JSON
# @return [Array<Company>] An array of Company objects
def initialize_companies(companies_data)
  companies_data.map do |company_data|
    # Validate: Ensure that all fields from COMPANY_JSON_FIELDS exist in the company_data hash
    if COMPANY_JSON_FIELDS.all? { |field| company_data.key?(field) }
      Company.new(
        company_data['id'],
        company_data['name'],
        company_data['email_status'],
        company_data['top_up']
      )
    end
  end.compact # Remove nil values from the result array
end

# Create an array of user object from the given raw data
#
# @param [Array<Hash>] users_data An array of raw user data from JSON
# @return [Array<User>] An array of User objects
def initialize_users(users_data)
  users_data.map do |user_data|
    # Validate: Ensure that all fields from USER_JSON_FIELDS exist in the user_data hash
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
  end.compact # Remove nil values from the result array
end

# Assign active users with updated token to correct company
#
# @param [Array<User>] users An array of User objects
# @param [Array<Company>] companies An array of Company objects
def assign_users_to_companies(users, companies)
  users.each do |user|
    # Select only active user
    next unless user.active_status

    # Find company based on user.company_id
    company = companies.find { |co| co.id == user.company_id }
    next unless company

    user.update_tokens(company.top_up)
    company.add_user(user)
  end
end

# Write the array of company to an output file sorted by company ID and users by last name
#
# @param [Array<Company>] companies An array of Company objects
# @param [String] output_file The file name to be written
def write_to_file(companies, output_file)
  File.open(output_file, 'w') do |file|
    companies
      .select { |company| company.total_top_ups > 0 } # Only select companies with top-ups > 0
      .sort_by(&:id) # Sort company by ID
      .each(&:sort_users) # Sort users within each company
      .each do |company|
        file.puts "Company Id: #{company.id}"
        file.puts "Company Name: #{company.name}"
        
        file.puts "Users Emailed:"
        write_users(file, company.emailed_users)
        
        file.puts "Users Not Emailed:"
        write_users(file, company.not_emailed_users)

        file.puts "\t\tTotal amount of top ups for #{company.name}: #{company.total_top_ups}"
        file.puts
    end
  end
end

# Write user details
#
# @param [IO] file The file object to write to
# @param [Array<User>] users An array of User objects
def write_users(file, users)
  users.each do |user|
    file.puts "\t\t#{user.full_name}, #{user.email}"
    file.puts "\t\t  Previous Token Balance, #{user.tokens}"
    file.puts "\t\t  New Token Balance #{user.new_balance}"
  end
end

if __FILE__ == $0
  puts "Starting script..."

  # Loads users data from JSON file
  users_data = load_json_data(USERS_FILE)
  if users_data.empty?
    exit
  end

  # Loads companies data from JSON file
  companies_data = load_json_data(COMPANIES_FILE)
  if companies_data.empty?
    exit
  end

  # Create an array of Companies object
  companies = initialize_companies(companies_data)

  # Create an array of Users object
  users = initialize_users(users_data)

  # Assign users to the correct companies and calculate the tokens
  assign_users_to_companies(users, companies)

  # Write company array to the output file sorted by company ID and user last name
  write_to_file(companies, OUTPUT_FILE)

  puts "Ending script..."
end
