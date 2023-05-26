require 'csv'

class CreateFromCsv
  def initialize(params = {})
    @file = params[:file]

    @valids = []
    @invalids = []
    @duplicates = []
    @registered = []
    @already_registered = []
  end

  def perform
    if valid_file?
      load_registers
      save_registers
    end

    result
  end

  def load_registers
    raise NotImplementedError, 'Abstract method, you should implement this method!'
  end

  def save_registers
    raise NotImplementedError, 'Abstract method, you should implement this method!'
  end

  def validates_presence_of_headers
    raise NotImplementedError, 'Abstract method, you should implement this method!'
  end

  def registers
    CSV.foreach(@file, headers: true) do |row|
      yield(row.to_h.symbolize_keys)
    end
  end

  private

  def valid_file?
    file_exists? and csv? and contains_default_headers? and contais_data?
  end

  def contains_default_headers?
    CSV.read(@file).first == validates_presence_of_headers
  end

  def contais_data?
    CSV.read(@file).length > 1
  end

  def csv?
    File.extname(@file) == '.csv'
  end

  def file_exists?
    !@file.nil?
  end

  def result
    struct_result.new(registered: @registered,
                      already_registered: @already_registered,
                      invalids: @invalids, duplicates: @duplicates,
                      valid_file?: valid_file?)
  end

  def struct_result
    @struct_result ||= Struct.new(:registered, :already_registered, :invalids, :duplicates, :valid_file?)
  end
end
