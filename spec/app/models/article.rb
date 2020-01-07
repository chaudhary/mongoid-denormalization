class Article
  include Mongoid::Document
  include Mongoid::Denormalization

  field :title
  field :body
  field :created_at, :type => Time

  belongs_to :author, :class_name => 'User'

  denormalize_from :author, :name
  denormalize_from :author, :email
end
