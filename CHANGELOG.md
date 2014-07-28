# Changelog

## v0.5

* A lot of code cleanup.
* Cleaned up the browsable API part.
  - html is now defined in an erb template and used a proper doctype, etc.
  - Changed the look of the html template a bit even though it's still not using stylesheets.
  - Cleaned up the yaml and json generation.
  - Allow yaml to be generated using both 'yml' and 'yaml' as the format parameter.

## v0.4

* Implemented two new string validations.
    - min_length
    - max_length

## v0.3

* Improved the error hash to contain more information about the error that occurred.

* Added possibility to override default error behaviour.

* Renamed `system_parameters` option to `allowed_undefined_parameters`.

* Don't show HEAD routes in the browsable API by default.

## v0.2

First usable version.
