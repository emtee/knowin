class Dataset
  require 'fileutils'
  # require 'iconv'

  include Mongoid::Document
  include Mongoid::Timestamps

  field :title, type: String
  field :description, type: String
  field :model_classname, type: String
  field :model_filename, type: String

  def self.save_data_model params
    begin
      Spreadsheet.client_encoding = 'UTF-8'
      book    = Spreadsheet.open params[:source_file].tempfile.path
      sheet1  = book.worksheet 0

      nu_model_name   = params[:source_file].original_filename.split(".")[0].downcase.underscore
      class_name      = nu_model_name.classify
      model_attrs     = sheet1.row(0).formatted.collect{|x| x.gsub("%","percent").gsub("&","n").gsub(".","").parameterize.underscore.to_sym}
      # model_attrs = sheet1.row(0).formatted.collect{|x| x.downcase.gsub("&","n").gsub(".","").gsub(" ","_").underscore.to_sym}
      model_attrs.shift #removing first element
      
      # Creating model file
      File.open(Rails.root + "app/models/#{nu_model_name}.rb", "w"){|f| f.write(
<<-CODE
#class #{class_name}
  include Mongoid::Document
  include Mongoid::Timestamps

  #{model_attrs.collect{|attribute| "field :#{attribute}"}.join("\n\t")}
#end       
CODE
      )}

      # Using the above created model file to initialize model 
      # Source : http://stackoverflow.com/questions/11764921/mongoid-creating-runtime-models-for-embedding
      model_filename  = "#{Rails.root}/app/models/#{nu_model_name}.rb"
      my_klass        = Object.const_set(class_name, Class.new)
      my_klass.class_eval File.open(model_filename).read #initializing the model for use
      
      sheet1.each 1 do |row|
        obj_attrs = Hash.new
        1.upto sheet1.last_row_index do |index|
          # model_attrs[index-1] coz we have already pushed the first element outta model_attrs
          obj_attrs.merge!({model_attrs[index-1].to_sym => row[index]}) rescue nil
        end
        # Dont save if the row is empty
        @new_obj = eval(class_name).create!(obj_attrs) unless obj_attrs.values.compact.size == 0
      end
      
    rescue Exception => e
      puts e.inspect
      return {:status => "failure", :errors => e}
    end

    return {
      :status => "success", 
      :dataset => {
        :title => params[:title].blank? ? params[:source_file].original_filename.split(".")[0].titleize : params[:title] , 
        :description => params[:description],  
        :model_classname => class_name, :model_filename => nu_model_name+".rb"
        }
      }
  end

end
