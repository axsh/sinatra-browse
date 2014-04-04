# sinatra-browse

Self documenting parameter declaration framework for Sinatra.

## What problem do we solve?

Sinatra has tools to define `GET`, `POST`, `DELETE` etc. routes. It doesn't have any tools to define parameters.

There exist several frameworks that generate documentation based on comment blocks above routes. The problem is you have to update these every time something is changed in the code. We have seen programmers forget this in too many projects.

## How do we solve it?

We believe in using actual code as documentation. Take a look at the following example.

```ruby
require "sinatra/base"
require "sinatra/browse"

class App < Sinatra::Base
  register Sinatra::Browse

  description "Creates a new user"
  param :display_name, :String, required: true
  param :type, :String, in: ["admin", "moderator", "user"], default: user
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

*Question: But we don't want to go look at source code just to get api documentation. What do we do?*

Simple. Sinatra-browse add a new GET route called `browse` to your sinatra application. Surfing to it in your browser will show a full human readable set of documentation. In the future we plan to not just limit this to documentation but actually turn it into a browsable API that you can easily call from your browser.

The syntax is inspired by the [sinatra-param](https://github.com/mattt/sinatra-param) and [thor](https://github.com/erikhuda/thor) projects.
