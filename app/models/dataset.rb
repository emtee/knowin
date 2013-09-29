class Dataset
  require 'fileutils'
  # require 'iconv'

  include Mongoid::Document
  include Mongoid::Timestamps

  field :title, type: String
  field :description, type: String
  field :model_classname, type: String
  field :model_filename, type: String
  field :user_count

  # attr_accessible :user_count, :id

  has_and_belongs_to_many :users

  # after_save    :update_user_count
  # after_destroy :update_user_count

  # scope :recently_viewed
  scope :most_popular, lambda{|x=5| desc(:user_count).limit(x)}
  scope :newly_added, lambda{|x=5| desc(:created_at).limit(x)}

  def self.update_user_count
    all.each do |d|
      d.update_attribute(:user_count, d.users.count)
    end
  end  

  def init_model
    my_klass        = Object.const_set(model_classname, Class.new)
    my_klass.class_eval File.open(Rails.root+"app/models/"+model_filename).read #initializing the model for use
    eval(model_classname)
  end

  def content
    humanize_content(
      Dataset.first.init_model.all.as_json(
          :except => [:created_at, :updated_at, :_id],
        )
      ) 
  end

  def humanize_content target_json
    target_json.collect do |obj|
      hsh = Hash.new
      obj.each do |key, val|
        hsh[key.humanize] = val
      end
      hsh
    end
    # hash.inject({}){|new_hash, key_value|
    #   key, value = key_value
    #   raise key_value.inspect
    #   new_hash[key.humanize] = value
    #   new_hash
    # }
  end

  def self.save_data_model params
    nu_model_name   = params[:source_file].original_filename.split(".")[0].downcase.underscore
    class_name      = nu_model_name.classify
    result          = nil 

    filetype        = params[:source_file].original_filename.split(".").last rescue nil
    if filetype == "xls"
      result        = read_excel params, nu_model_name, class_name
    elsif filetype == "csv"
      result        = read_csv params, nu_model_name, class_name
    end
    return {:status => "failed"} unless result
    if result[:status] == "success"

      return {
        :status => "success", 
        :dataset => {
          :title => params[:title].blank? ? params[:source_file].original_filename.split(".")[0].titleize : params[:title] , 
          :description => params[:description],  
          :model_classname => class_name, :model_filename => nu_model_name+".rb"
          }
        }
    else
      return result
    end
  end

  def self.read_excel params, nu_model_name, class_name
    Spreadsheet.client_encoding = 'UTF-8'
    book    = Spreadsheet.open params[:source_file].tempfile.path
    sheet1  = book.worksheet 0

    # model_attrs = sheet1.row(0).formatted.collect{|x| x.downcase.gsub("&","n").gsub(".","").gsub(" ","_").underscore.to_sym}
    model_attrs     = sheet1.row(0).formatted.collect{|x| x.gsub("%","percent").gsub("&","n").gsub(".","").parameterize.underscore.to_sym}
    model_attrs.shift #removing first element

    create_model(class_name, model_attrs, nu_model_name)
    # Uploading file contents
    sheet1.each 1 do |row|
      obj_attrs = Hash.new
      1.upto sheet1.last_row_index do |index|
        # model_attrs[index-1] coz we have already pushed the first element outta model_attrs
        obj_attrs.merge!({model_attrs[index-1].to_sym => row[index]}) rescue nil
      end
      # Dont save if the row is empty
      @new_obj = eval(class_name).create!(obj_attrs) unless obj_attrs.values.compact.size == 0
    end
    return {:status => "success"}
  end

  def self.read_csv params, nu_model_name, class_name
   csv  = SmarterCSV.process(params[:source_file].tempfile.path, :file_encoding => 'windows-1251:utf-8')
    if File.exists?(Rails.root + "app/models/#{nu_model_name}.rb")
      eval(class_name).destroy_all
    else
      # raise csv.first.keys.collect{|x|x.to_s.parameterize.underscore.squeeze("_")}.inspect
      model_attrs = csv.first.keys.collect{|x|x.to_s.parameterize.underscore.squeeze("_")}
      create_model(class_name, model_attrs, nu_model_name)
    end
    csv.each do |row|
      eval(class_name).create!(Hash[row.map{|k,v| [k.to_s.parameterize.underscore.squeeze("_"), v]}]) 
    end
    return {:status => "success"}
  end

  def self.create_model class_name, model_attrs, nu_model_name
    # Creating a model file for requested model
    File.open(Rails.root + "app/models/#{nu_model_name}.rb", "w"){|f| f.write(
<<-CODE
#class #{class_name}
  include Mongoid::Document
  include Mongoid::Timestamps

  #{model_attrs.collect{|attribute| "field :#{attribute}"}.join("\n\t")}
#end       
CODE
    )}
    # Using the above created model file to initialize the model (Source : http://stackoverflow.com/questions/11764921/mongoid-creating-runtime-models-for-embedding)
    model_filename  = "#{Rails.root}/app/models/#{nu_model_name}.rb"
    my_klass        = Object.const_set(class_name, Class.new)
    my_klass.class_eval File.open(model_filename).read #initializing the model for use
  end

end


















 # # Processing CSV in chunks
 #  def self.read_csv params, nu_model_name, class_name
 #    # csv_text = File.read(params[:source_file].tempfile.path).encode!('UTF-8', 'UTF-8', :invalid => :replace)
 #    # csv    = CSV.parse(csv_text, :headers => true)
 #    csv_chunks  = SmarterCSV.process(params[:source_file].tempfile.path, {:chunk_size => 100, :file_encoding => 'windows-1251:utf-8'})
 #    if File.exists?(Rails.root + "app/models/#{nu_model_name}.rb")
 #      eval(class_name).destroy_all
 #    else
 #      model_attrs = csv_chunks.first.first.keys.collect{|x|x.to_s}
 #      create_model(class_name, model_attrs, nu_model_name)
 #    end
 #    csv_chunks.each do |chunk|
 #      # we're passing a block in, to process each resulting hash / row (block takes array of hashes)
 #      # when chunking is enabled, there are up to :chunk_size hashes in each chunk
 #      eval(class_name).collection.insert( chunk )   # insert up to 100 records at a time
 #    end
 #    return {:status => "success"}
 #  end