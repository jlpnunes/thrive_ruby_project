require 'json'

# Abstract base class to load and validate JSON data
class AbstractParser
  # Loads and retrieves JSON data from a file
  #
  # @param [String] file_path The path of the file
  # @return [Array<Hash>] Array of hashes from JSON file
  def self.load_json_data(file_path)
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
    []
  end

  # Abstract method to be implemented by subclasses for validating fields
  # and creating objects
  #
  # @param [Array<Hash>] data Array of raw data to be validated
  # @return [Array<Object>] An array of valid objects created from raw data
  def self.initialize_objects(data)
    raise NotImplementedError, 'Subclasses must implement this method'
  end

  # Method to load objects from a file and return an array of objects
  #
  # @param [String] file_path Path to the companies JSON file
  # @return [Array<Object>] Array of objects
  def self.load_and_initialize(file_path)
    json_data = load_json_data(file_path)
    initialize_objects(json_data)
  end
end