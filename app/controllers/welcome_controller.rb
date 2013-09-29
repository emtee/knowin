class WelcomeController < ApplicationController
  before_filter :authenticate_user!
  protect_from_forgery
  require 'fileutils'
  # require 'iconv'

  # http://stackoverflow.com/questions/6061838/running-a-constructer-from-within-a-controller
  def upload

    # raise params.inspect
    # x = Spreadsheet.open(params[:source_file].tempfile.path)

    Spreadsheet.client_encoding = 'UTF-8'
    tmp = params[:source_file].tempfile
    raise tmp.path.inspect
    book = Spreadsheet.open tmp.path
    sheet1 = book.worksheet 0

    model_name  = params[:source_file].original_filename.split(".")[0].downcase.underscore
    class_name  = model_name.classify
    model_attrs = sheet1.row(0).formatted.collect{|x| x.gsub("%","percent").gsub("&","n").gsub(".","").parameterize.underscore.to_sym}
    # model_attrs = sheet1.row(0).formatted.collect{|x| x.downcase.gsub("&","n").gsub(".","").gsub(" ","_").underscore.to_sym}
    model_attrs.shift #removing first element
    
    # Creating model file
    File.open(Rails.root + "app/models/#{model_name}.rb", "w"){|f| f.write(
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
      
    model_filename  = "#{Rails.root}/app/models/#{model_name}.rb"
    my_klass        = Object.const_set(class_name, Class.new)
    my_klass.class_eval File.open(model_filename).read
    # new_obj         = eval(class_name).new
    # new_obj.save
    # raise new_obj.inspect

    sheet1.each 1 do |row|
      obj_attrs = Hash.new
      1.upto sheet1.last_row_index do |index|
        # model_attrs[index-1] coz we have already pushed the first element outta model_attrs
        obj_attrs.merge!({model_attrs[index-1].to_sym => row[index]}) rescue nil
      end
      # Dont save if the row is empty
      @new_obj = eval(class_name).create(obj_attrs) unless obj_attrs.values.compact.size == 0
    end


    # raise x.inspect
    # file_content = File.read(Rails.root + "db/data/mcc_list.csv")
    # csv    = CSV.parse(file_content, :headers => true)
    # csv.each do |row|
    #   row["code"] = row["code"].gsub(".","")
    #   row = row.to_hash.with_indifferent_access
    #   cc = Cc.find_by_title(row["title"])
    #   cc.update_attributes(row.to_hash.symbolize_keys) if cc
    #   puts "not found #{row['title'].inspect}" unless cc
    #   print "."
    # end
    redirect_to root_path
  end

  def create_default_admin
    user = User.new({:email => "amit.scorpio42@gmail.com", :username => "admin", :password => "Password@1234", 
      :password_confirmation => "Password@1234"})
    user.save
    redirect_to root_path
  end
end
