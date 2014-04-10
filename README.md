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

`format` This validation is only for parameters of type `:String`. You can pass a regular expression that the string provided must match to.

```ruby
param :alphanumeric, :String, format: /^[0-9A-Za-z]*$/
```

## Error handling

When a validation fails, a standard 400 error will be returned. You can override this and do your own error handling using `on_error`.

```ruby
param :lets_fail, :Integer, in: 1..9, on_error: proc { halt 404, "if you're not giving us a number between 1 and 9, we're going to pretend not to be here!" }
get 'example_route' do
  # This is the scope that the on_error proc will be executed in.
end
```

If a request is made that fails validation on the *lets_fail* parameter, then the proc provided to `on_error` will be called **in the same scope as your route**. Therefore you have access to Sinatra keywords such as *halt*.

## Parameter transformation

You can use transform to execute a quick method on any prameter provided. Anything that responds to *to_proc* will do.

```ruby
param :only_caps, :String, transform: :upcase
param :power_of_two, :Integer, transform: proc { |n| n * n }
```
## Removing undefined parameters

By default sinatra-browse removes all parameters that weren't defined. You can disable this behaviour with the following line.

    disable :remove_undefined_parameters

You can also set a `system_parameters` variable to allow for a select few parameters that aren't removed. By default this is set to *[ "splat", "captures" ]*.

    set system_parameters: [ "id", "username", "password" ]
