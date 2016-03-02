# Blueshift

The Amazon Redshift adapter for Sequel

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'blueshift'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install blueshift

## Usage

[`create_table`](http://sequel.jeremyevans.net/rdoc/classes/Sequel/Database.html#method-i-create_table) Options:

    :distkey => column name

        The Distribution Key. When specified, the :diststyle is set to :key unless otherwise specified

    :diststyle => `:even` (default), `:key`, or `:all`

        The Distribution Style. This option has no effect unless `:distkey` is also specified

    :sortkeys => a list of column names

        The Sort Keys. Depending on your `:sortstyle`, there is a maximum number of sortkeys that you can specify:
          Compound: up to 400 sortkeys
          Interleaved: up to 8 sortkeys
        
    :sortstyle => :compound (default) or :interleaved
    
        The Sort Style. This option has no effect unless `:sortkeys` is also specified
        
For example:

```ruby
create_table :chocolates, distkey: :region, diststyle: :all, sortkeys: [:richness, :organic], sortstyle: :interleaved do
    String  :region
    Integer :richness
    boolean :organic
    String  :description
end
```
       
## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/influitive/blueshift.

