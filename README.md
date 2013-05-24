sitemap-checker
===============

Checks each `<url>` and `<image:image>` in a sitemap to verify the resource is accessible.

### Rules ###

Each url and image is checked.  A resource is considered "passing" if it returns an HTTP status code under 400 (ie. various types of 300-level redirects are counted as success).

### Usage ###

Run the script from the command line.  The first argument is the domain to check.  The second argument is the delay in seconds between requests.  The [delay] argument is optional.  It defaults to 1 second.

	$ ruby check.rb [domain] [delay]

#### Example #####

	$ ruby check.rb example.com 5

### Tests ###

Todo: Add them.

