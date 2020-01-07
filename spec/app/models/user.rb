class User
  include Mongoid::Document

  field :name, :type => String
  field :email, :type => String
  field :nickname, :type => String
  field :location, :type => Array

  has_one :post
  has_many :comments, :inverse_of => :user
  has_many :moderated_comments, :class_name => "Comment", :inverse_of => :moderator
  has_many :articles, :inverse_of => :author
end
