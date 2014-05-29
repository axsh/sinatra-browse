# sinatra-browse

Parameter declaration framework and browsable API for Sinatra.

## What problem do we solve?

Sinatra has tools to define `GET`, `POST`, `DELETE` etc. routes. It doesn't have any tools to define their parameters.

There exist several frameworks that generate documentation based on comment blocks above routes. The problem is you have to update these every time something is changed in the code. We have seen programmers forget this in too many projects.

## How do we solve it?

**Parameter Declaration**

We believe in using actual code as documentation. Take a look at the following example.

```ruby
require "sinatra/base"
require "sinatra/browse"

class App < Sinatra::Base
  register Sinatra::Browse

  description "Creates a new user"
  param :display_name, :String, required: true
  param :type, :String, in: ["admin", "moderator", "user"], default: "user"
  param :age, :Integer
  param :gender, :String, in: ["m", "w", "M", "W"], transform: :upcase
  param :activated, :Boolean, default: false
  param :email, :String, format: /^([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})$/
  post "/users" do
    # ... some code that creates a new user
  end
end
```

Here we have a clear list of what parameters are expected and how they are validated. Since this is code and not a comment block, it will always be up to date with the behaviour of our application.

The syntax is inspired by the [sinatra-param](https://github.com/mattt/sinatra-param) and [thor](https://github.com/erikhuda/thor) projects.

**Browsable API**

Sinatra-browse allows you to surf to your API. This works as documentation and allows you to send requests and see their responses directly in your browser.

    http://<api_ip_address>:<api_port>/browse

*Remark:* This is still work in progress. Right now the page only shows some simple documentation.

## Parameter types

At the time of writing four parameter types are available.

* `:String`
* `:Integer`
* `:Float`
* `:Boolean` ["1/0", "true/false", "t/f", "yes/no", "y/n"]

## Default values

You can set default values in your declarations. These will be used when the parameter in question wasn't provided in the request. You can either set the default value or provide a proc to generate it.

```ruby
param :media_type, :String, default: "book"
param :year, :Integer, default: lambda { Time.now.year }
```

## Parameter validation

You can write some quick validation logic directly in the parameter declaration. If the validation fails, either a standard 400 error will be returned or a custom error block will execute if provided.

`required` Fails if this parameter is not provided in the request.

```ruby
param :you_must_include_me, :String, required: true
```

`depends_on` Some times there are parameters that are required by other parameters. Use `depends_on` to implement this. The example below will allow you to send *post_something* without any other parameters. If you send *user_name* though, you will be required to send *password* along with it.

```ruby
param :post_something, :String
param :user_name, :String, depends_on: :password
param :password, :String
```

`in` Fails if this parameter is not included in the values set by `in`. You can use anything that responds to *.member?* like an array or a range.

```ruby
param :single_digit, :Integer, in: 1..9
param :small_prime_number, :Integer, in: Prime.take(10)
param :order, :String, in: ["ascending", "descending"]
```

### String validation

The following parameter validators can only be used for parameters of type `:String`.

`format` You can pass a regular expression that the string provided must match to.

```ruby
param :alphanumeric, :String, format: /^[0-9A-Za-z]*$/
```

`min_length` The string must be of this length or longer.

```ruby
param :five_or_longer, :String, min_length: 5
```

`max_length` The string must be of this length or shorter.

```ruby
param :five_or_shorter, :String, max_length: 5
```

## Parameter transformation

You can use transform to execute a quick method on any prameter provided. Anything that responds to *to_proc* will do.

```ruby
param :only_caps, :String, transform: :upcase
param :power_of_two, :Integer, transform: proc { |n| n * n }
```

## Error handling

When a validation fails, a standard 400 error will be returned. You can override this and do your own error handling using `on_error`.

```ruby
param :lets_fail, :Integer, in: 1..9, on_error: proc { halt 400, "Must be between 1 and 9!" }
get 'example_route' do
  # This is the scope that the on_error proc will be executed in.
end
```

If a request is made that fails validation on the *lets_fail* parameter, then the proc provided to `on_error` will be called **in the same scope as your route**. Therefore you have access to Sinatra keywords such as *halt*.

### The error hash

If you want to write a bit more intricate error handling, you can add *the error hash* as an argument to your `on_error` proc. This hash holds some extra information about what exactly went wrong.

```ruby
param :lets_fail, :Integer, in: 1..9, required: true, on_error: proc { |error_hash|
  case error_hash[:reason]
  when :in
    halt 400, "Must be between 1 and 9!"
  when :required
    halt 400, "Why u no give us lets_fail?"
  end
}
get 'example_route' do
  # Some code
end
```

The error hash contains the following keys:

* `:reason` This tells you what validation failed. Possible values could be `:in`, `:required`, `:format`, etc.
* `:parameter` The name of the faulty parameter.
* `:value` The value our parameter had which caused it to fail validation.
* `:type` The type of our parameter. Could be `:String`, `:Integer`, etc.
* Any validation keys that were set in the parameter declaration will also be available in the error hash.

### Overriding default error behaviour

So we explained how to do error handling for single parameters. Now what if we wanted to set error handling for the entire application? You can do that with the `default_on_error` method.

```ruby
default_on_error do |error_hash|
  case error_hash[:reason]
  when :required
    halt 400, "#{error_hash[:parameter]} is required! provide it!"
  else
    _default_on_error(error_hash)
  end
end

param :a, :String, in: ["a"], required: true
param :b, :String, format: /^bbb$/
get "/features/default_error_override" do
  # Again this is the scope that default_on_error is executed in
  params.to_json
end
```

The block we passed to the `default_on_error` method will be called or every parameter in our application that fails validation and does not have its own `on_error` block. Notice how inside our `default_on_error`

You might notice that in our example, the `default_on_error` method makes a call to `_default_on_error`. The latter is a fallback to sinatra-browse's standard error behaviour. It's available form both the `default_on_error` block and procs passed to `on_error` in parameter declarations.

## Removing undefined parameters

By default sinatra-browse removes all parameters that weren't defined. You can disable this behaviour with the following line.

```ruby
disable :remove_undefined_parameters
```

You can also set a `allowed_undefined_parameters` variable to allow for a select few parameters that aren't removed.

```ruby
set allowed_undefined_parameters: [ "id", "username", "password" ]
```

## Named parameters in route patterns

Unfortunately you are not able to use Sinatra-browse for named parameters in the route definition. Take the following example.

```ruby
get 'foo/:bar' do
  # some code
end
```

You will ***not*** be able to define the parameter `bar`. This is because Sinatra-browse does its thing in a before block and these parameters aren't added to the `params` hash until the route itself gets executed.

Some exta discussion of this problem can be found [here](https://github.com/sinatra/sinatra/issues/417).
