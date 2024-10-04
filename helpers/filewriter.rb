# This class writes the company data to an output file
class FileWriter

  # Write the companies and users data to an output file, sorted by 
  # company ID and users by last name.
  #
  # @param [Array<Company>] companies An array of Company objects
  # @param [String] output_file The file path to be written
  def self.write_to_file(companies, output_file)
    File.open(output_file, 'w') do |file|
      # Filter companies with top-ups > 0, sort by company ID, and sort users 
      # within each company by last name
      companies
        .select { |company| company.total_top_ups > 0 }
        .sort_by(&:id)
        .each(&:sort_users) # Sort users within each company
        .each do |company|
          write_company_details(file, company)
        end
    end
  end

  private

  # Write company details
  #
  # @param [IO] file The file object to write to
  # @param [Company] company A Company object
  def self.write_company_details(file, company)
    file.puts "Company Id: #{company.id}"
    file.puts "Company Name: #{company.name}"
    
    file.puts "Users Emailed:"
    write_users(file, company.emailed_users)
    
    file.puts "Users Not Emailed:"
    write_users(file, company.not_emailed_users)

    file.puts "\t\tTotal amount of top ups for #{company.name}: #{company.total_top_ups}"
    file.puts
  end
  
  # Write user details
  #
  # @param [IO] file The file object to write to
  # @param [Array<User>] users An array of User objects
  def self.write_users(file, users)
    users.each do |user|
      file.puts "\t\t#{user.full_name}, #{user.email}"
      file.puts "\t\t  Previous Token Balance, #{user.tokens}"
      file.puts "\t\t  New Token Balance #{user.new_balance}"
    end
  end
end