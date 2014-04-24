### Fetchable

This Rails plugin helps you sync ActiveRecords with remote resources. It's
convenient for writing bots, scrapers, and the like.

Notes:

* Not complete yet - the examples below are partly a roadmap and won't all
  work.
* It's my first Rails gem, so I'm learning as I go here.

### Basic usage

Fetchable retains call results for you.

    class Image < ActiveRecord::Base
      include Fetchable
    end

    image = Image.create(url: 'http://upload.wikimedia.org/wikipedia/en/b/bc/Wiki.png')
    image.fetch
    puts image.resource.size # 12345
    puts image.live_resource? # true

### Storage

Fetchable optionally stores the retrieved payload via pluggable storage modules.

    image.fetch
    MyImageTool.brighten!(file_path: image.store_key)

### Re-fetch support

Fetchable conserves energy. HTTP "memento" standards (eTags and timestamp) are
leveraged to avoid unnecessarily repeating stuff.

    image.fetch # first fetch creates a resource record
    puts image.status # 200
    image.fetch # second re-fetch only does a full download if the image changed
    puts image.status # 304

### Callbacks

Fetchable lets you register for interesting events, just like the usual
ActiveRecord callbacks.

    class Image < ActiveRecord::Base

      include Fetchable

      before_fetch :cancel_if_server_too_busy
      after_fetch_update :save_image_dimensions
      after_fetch_error :report_problem
      after_fetch_redirect :save_url_alias
      after_fetch :log_fetch

    end

### Scheduling fetches

Fetchable helps you schedule recurring fetches.

    class Image
      settings.scheduler = Fetchable::Schedulers::SimpleScheduler.new(
        success_wait: 1.hour,
        fail_wait: 2.hours
      )

    Image.ready_for_fetch.find_each { |i| i.fetch }

### Performing fetches

Fetchable includes some basic support for performing the actual fetches.

### Future plans

Track permanent redirects in another table

Possible options in the future:
* Migration support
* changed\_at: Recognise same content transmission via fingerprint (pseudo-304)
* Enforce unique URLs (and maybe canonical URLs)

### Setup

Create a "resources" table. For now, [see this
example](https://github.com/playerfm/fetchable/blob/master/test/dummy/db/migrate/01_create_resources.rb).

For each of your fetchable classes, add a add an integer `resource_id` int
column and a string 'url' column.

### Contributing

Contributions are welcome. Please include tests and ensure it passes
[Travis](https://travis-ci.org/playerfm/fetchable). Run tests as follows (I
have brake aliased to `bundle exec rake` and the project includes single\test
gem for convenience):

> brake # runs all tests
> brake test:FetchableTest # run a single test class
> brake test:FetchableTest:test\_attribs # run a single test method

By default, the test web host is the remote TestData instance at
http://testdata.player.fm. It's faster to run tests locally by installing the
[testdata](https://github.com/playerfm/testdata) server. Once running on your
machine, point the environment variable TESTDATA\_HOST to your local server.
