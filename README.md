# Git Heroes

Ever wanted to know your your team's top contributors are?

`git heroes` will tell you, based on their Github activity (pull requests,
comments, and merges).

**Caveat Emptor**: no hard metric that measures individuals is reliable. Please do
not use this to estimate someone's productivity. In combination with other
tools, it can be effectivee to detect trends, though.

## Installation

    $ gem install git-heroes

To preserve your Github API usage limit, the tool requires locally running
Redis instance for caching.

## Usage

    $ git heroes -r <your-organization> -t <github-token>

Details:

    Usage: bin/git-heroes [options]
        -r, --organization ORG   Progress organization ORG (required)
        -o, --output FILE        Save report to FILE
        -t, --token TOKEN        A Github authentication token (defaults to GITHUB_TOKEN)
        -w, --weeks WEEKS        Report on the last WEEKS weeks (default 12).
        -v, --verbose            Run verbosely
        -h, --help               Show this message

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
