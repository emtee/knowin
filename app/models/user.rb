class User
  include Mongoid::Document
  include Mongoid::Timestamps
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :username

  ## Database authenticatable
  field :email,              :type => String, :default => ""
  field :username,           :type => String, :default => ""
  field :encrypted_password, :type => String, :default => ""

  # ## Recoverable
  # field :reset_password_token,   :type => String
  # field :reset_password_sent_at, :type => Time

  ## Rememberable
  field :remember_created_at, :type => Time

  # ## Trackable
  field :sign_in_count,      :type => Integer, :default => 0
  field :current_sign_in_at, :type => Time
  field :last_sign_in_at,    :type => Time
  field :current_sign_in_ip, :type => String
  field :last_sign_in_ip,    :type => String

  ## Confirmable
  # field :confirmation_token,   :type => String
  # field :confirmed_at,         :type => Time
  # field :confirmation_sent_at, :type => Time
  # field :unconfirmed_email,    :type => String # Only if using reconfirmable

  ## Lockable
  # field :failed_attempts, :type => Integer, :default => 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,    :type => String # Only if unlock strategy is :email or :both
  # field :locked_at,       :type => Time

  ## Token authenticatable
  # field :authentication_token, :type => String
  field :dashboard, :type => String, :default => "On" # :else => "Off"
  field :recent_views, :type => Array

  has_and_belongs_to_many :datasets

  validates :username, uniqueness: true, presence: true

  # after_save :increment_user_count
  # after_destroy :decrement_user_count
 
  # def increment_user_count
  #   datasets.each do |dataset|
  #     # Dataset.find_by(title: dataset.title).user_count += 1
  #     dataset.update_attribute(:user_count, dataset.users.count)
  #   end
  # end
 
  # def decrement_user_count
  #   puts "I AM HREREREREREREEE"
  #   self.datasets.each do |dataset|
  #     # Dataset.find_by(title: dataset.title).user_count -= 1
  #   dataset.update_attribute(:user_count, dataset.users.count)
  #   end
  # end
  def update_recent_views dataset
    cur_recent_views = recent_views || []
    update_attribute(:recent_views, cur_recent_views.unshift(dataset.id)[0..4]) unless cur_recent_views.collect{|x|x.to_s}.include? dataset.id.to_s
  end

  def recently_viewed_datasets
    recent_views.collect{|dataset_id| Dataset.find(dataset_id).as_json(
      :only => [:_id, :title, :description]
      )}.compact rescue []
  end
end