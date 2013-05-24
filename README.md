sitemap-checker
===============

Checks each `<url>` and `<image>` in a sitemap to verify the resource is accessible.

### Rules ###

Each url and image is checked.  A resource is considered "passing" if it returns an HTTP status code under 400 (ie. varous types of redirects are counted as success).

### Usage ###

Run the script from the command line.  The first argument is the domain to check.  The second argument is the delay in seconds between requests.

	$ ruby check.rb [domain] [delay]

#### Example #####

	$ ruby check.rb example.com 5
