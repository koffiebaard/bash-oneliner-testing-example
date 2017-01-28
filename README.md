# Bash one-liner testing example
Example on a testing framework based solely on bash one-liners. It's validation testing on the website and API of [Consolia](https://consolia-comic.com), my webcomic.

What does it do?
I like to know certain things about my website / API when deploying. Things i can keep checking always. Things like:

- Are the html pages / json responses being compressed?

- Is https working? Using the right tls negotiation protocol?

- Is Varnish caching properly? Is it skipping the cache wherever it should?

- Does the homepage show the latest comic? Is that comic image returning a 200?

- Is the Cache-Control header set properly for all assets in the pages?

- Are all other pages returning 200's? Are requests to the assets folders returning 403's? Are redirect endpoints returning 303's? Are non-existent pages returning 404's?

Etcetera. This simple script does that for me, using nothing but bash one-liners.
