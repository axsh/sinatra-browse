# sinatra-browse

Self documenting parameter declaration framework for Sinatra.

## What problem do we solve?

Sinatra has a very good and easy to read syntax for defining `GET`, `POST`, `DELETE` etc. routes. What it doesn't have is is a good way to declare parameters. Routes tend to get cluttered with inline parameter validations. There's no clear view of what parameters a route takes and what possible values they may have. There are a couple of frameworks out there that allow you to remedy this by writing big blocks of comments above routes but that method is still flawed. While it does give you a decent overview, you are still required to write all the inline validations just like you were before. Besides, you now also have the additional work of updating the comment blocks every time you change something in the code. All too often programmers change parameter behaviour and forget to update the comments.

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
