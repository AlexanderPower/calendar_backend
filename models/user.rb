class User
  include Mongoid::Document
  field :email, type: String
  field :password, type: String
  
  validates :email, presence: true, uniqueness: true
  validates :password, presence: true
  
  def authenticate(pass)
	password==pass
  end
end
