class Comment
  include Mongoid::Document
  include Mongoid::Denormalization

  field :body

  belongs_to :post, :inverse_of => :comments
  belongs_to :user, :inverse_of => :comments
  belongs_to :moderator, :class_name => "User", :inverse_of => :moderated_comments

  denormalize_from :user, :location
  denormalize_from :user, :name
  denormalize_from :user, :email
  denormalize_from :post, :created_at
  denormalize_from :moderator, :nickname, denormalized_field_name: :mod_nickname
end
