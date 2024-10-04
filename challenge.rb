##
# This script reads user and company data from JSON files, assign
# users to companies, update tokens, and write the results to a file.
#
require_relative 'helpers/filewriter'
require_relative 'models/company'
require_relative 'models/user'
require_relative 'parsers/company_parser'
require_relative 'parsers/user_parser'

# Constants that store path of the files
USERS_FILE = 'resources/data/users.json'
COMPANIES_FILE = 'resources/data/companies.json'
OUTPUT_FILE = 'resources/output/output.txt'

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

if __FILE__ == $0
  puts "Starting script..."

  # Create an array of Companies object
  companies = CompanyParser.load_and_initialize(COMPANIES_FILE)
  if companies.empty?
    exit
  end

  # Create an array of Users object
  users = UserParser.load_and_initialize(USERS_FILE)
  if users.empty?
    exit
  end

  # Assign users to the correct companies and calculate the tokens
  assign_users_to_companies(users, companies)

  # Write company array to the output file sorted by company ID and user last name
  file_writer = FileWriter.write_to_file(companies, OUTPUT_FILE)

  puts "Ending script..."
end
