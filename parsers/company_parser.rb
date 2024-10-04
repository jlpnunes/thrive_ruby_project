require_relative 'abstract_parser'

# Concrete class for handling Company JSON data
class CompanyParser < AbstractParser
    COMPANY_JSON_FIELDS = ['id', 'name', 'email_status', 'top_up']
  
    # Override the abstract method to create and validate company objects
    #
    # @param [Array<Hash>] companies_data Array of raw company data
    # @return [Array<Company>] Array of valid Company objects
    def self.initialize_objects(companies_data)
      companies_data.map do |company_data|
        if COMPANY_JSON_FIELDS.all? { |field| company_data.key?(field) }
          Company.new(
            company_data['id'],
            company_data['name'],
            company_data['email_status'],
            company_data['top_up']
          )
        end
      end.compact # Remove nil values (invalid data)
    end
  end
