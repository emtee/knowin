class WelcomeController < ApplicationController
  require 'fileutils'
  require 'iconv'

  # http://stackoverflow.com/questions/6061838/running-a-constructer-from-within-a-controller
  def upload

    # raise params.inspect
    # x = Spreadsheet.open(params[:source_file].tempfile.path)

    tmp = params[:source_file].tempfile

    Spreadsheet.client_encoding = 'UTF-8'

    book = Spreadsheet.open tmp.path

    sheet1 = book.worksheet 0

    model_name  = params[:source_file].original_filename.split(".")[0].downcase.underscore
    class_name  = model_name.classify
    model_attrs = sheet1.row(0).formatted.collect{|x| x.gsub("&","n").gsub(".","").parameterize.underscore.to_sym}
    model_attrs.shift #removing first element
    model_attrs = model_attrs.collect{|attribute| "field :#{attribute}"}.join("\n\t")
    
    # Creating model file
    File.open(Rails.root + "app/models/#{model_name}.rb", "w"){|f| f.write(
<<-CODE
#class #{class_name}
  include Mongoid::Document
  include Mongoid::Timestamps

  #{model_attrs}
#end       
CODE
    )}

    # Using the above created model file to initialize model 
    # Source : http://stackoverflow.com/questions/11764921/mongoid-creating-runtime-models-for-embedding
      
    model_filename = "#{Rails.root}/app/models/#{model_name}.rb"
    my_klass = Object.const_set(class_name, Class.new)
    # my_klass.class_eval <<-ENDSRC
    #   #{model_attrs}
    # ENDSRC
    my_klass.class_eval File.open(model_filename).read

    # raise eval(class_name).new.inspect
    new_obj = eval(class_name).new
    new_obj.save
    raise new_obj.inspect









# p = "Post"
# Kernel.const_get(class_name)
# eval(class_name)
# class_name.constantize  
  # x = eval(class_name).new
  #   raise x.inspect

    0.upto sheet1.last_row_index do |index|
      row = sheet1.row(index)
      if index = 0
        # create_file "lib/fun_party.rb" do
        #   "my config"
        # end

        model_attrs = row.formatted.formatted.collect{|x|x.humanize} 
      end 
      # raise row.formatted.formatted.collect{|x|x.parameterize.underscore.to_sym}.inspect
      # row.formatted.each do |row_elem|
        # puts row_elem
      # end
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
  end
end
