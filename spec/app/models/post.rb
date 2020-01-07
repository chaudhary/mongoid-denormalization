class Post
  include Mongoid::Document
  include Mongoid::Denormalization

  field :title
  field :body
  field :created_at, :type => Time

  belongs_to :user
  has_many :comments

  denormalize_from :user, :location
  denormalize_from :user, :name
  denormalize_from :user, :email
end
