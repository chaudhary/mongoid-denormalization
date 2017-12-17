# Mongoid::Denormalization

Helper module for denormalizing association attributes in Mongoid models & embedded models.
Supports rails 5.1.4, mongoid 6.2, ruby 2.4.2

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mongoid-denormalization'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install mongoid-denormalization

## Usage

In your model:
$ # Include the helper method
$ include Mongoid::Denormalization
$
$ # Define your denormalization
$ denormalize_from(:user, :name) # this will add a user_name field on your model
$ denormalize_from(:user, :email) # this will add a user_email field on your model


Optionally, you can also write it as
$ denormalize_from(:user, :name, :denormalized_field_name => :nusername) # this will add a username field on your model
$ denormalize_from(:user, :email, :denormalized_field_name => :useremail) # this will add a useremail field on your model

Lets say we have a company model with embedded jobs in it. We want to denormalize user_name and user_email in jobs.
We can write the following code in our jobs model:

denormalize_from(:user, :name, to_klass_infos: [{
  klasses: [::Company],
  selector_proc: Proc.new do |id, value|
    {:jobs => {"$elemMatch" => {:user_id => id, :user_name => {"$ne" => value}}}}
  end,
  updator: "jobs.$.user_name",
  index_key: "jobs.user_id"
}])
denormalize_from(:user, :email, to_klass_infos: [{
  klasses: [::Company],
  selector_proc: Proc.new do |id, value|
    {:jobs => {"$elemMatch" => {:user_id => id, :user_email => {"$ne" => value}}}}
  end,
  updator: "jobs.$.user_email",
  index_key: "jobs.user_id"
}])

You can call force_denormalize also,
company.force_denormalize # this will simply sync all the denormalized fields and will not triiger a save on document.
company.force_denormalize! # this will sync all the denormalized fields and will also triiger a save on document.

Note: you should also create proper db indexes required, otherwise the module may through an error.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/mongoid-denormalization. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Mongoid::Denormalization project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/mongoid-denormalization/blob/master/CODE_OF_CONDUCT.md).
