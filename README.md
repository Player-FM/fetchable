### Acts As Fetchable

This Rails plugin helps you sync ActiveRecords with remote resources. It's
convenient for writing bots, scrapers, and the like.

Notes:

* Not complete yet - the examples below are partly a roadmap and won't all
  work.
* It's my first Rails gem, so I'm learning as I go here.

### Basic usage

Fetchable retains call results for you.

    class Image < ActiveRecord::Base
      acts_as_fetchable
    end

    image = Image.create(url: 'http://upload.wikimedia.org/wikipedia/en/b/bc/Wiki.png')
    image.fetch
    image.store_key # "/public/image123"
    File.exists?(image.store_key) # 123
    puts image.resource.size # 12345
    puts image.live_resource? # true

### Re-fetch support

Fetchable conserves internet energy. HTTP "memento" standards (eTags and
timestamp) are leveraged to avoid unnecessary work.

    image.fetch # first fetch creates a resource record
    puts image.status # 200
    image.fetch # second re-fetch only does a full download if the image changed
    puts image.status # 304

### Callbacks

Fetchable lets you register for interesting fetch events, just like the usual
ActiveRecord callbacks.

    class Image < ActiveRecord::Base

      acts_as_fetchable

      before_fetch :cancel_if_server_too_busy
      after_fetch_update :save_image_dimensions
      after_fetch_error :report_problem
      after_fetch_redirect :save_url_alias
      after_fetch :log_fetch

    end

### Flexible Storage

Fetchable can store the retrieved payload where you want it (or not at all).

    acts_as_fetchable store: Fetchable::Stores::DBStore.new(column: 'content')
    image.fetch
    image.pluck(:content) # image data

### Scheduling fetches

Fetchable helps you schedule recurring fetches.

  class Image
    acts_as_fetchable scheduler: Fetchable::Schedulers::SimpleScheduler.new(
      success_wait: 1.hour,
      fail_wait: 2.hours
    )
  end
  Image.ready\_for\_fetch.find\_each { |i| i.fetch }

### Performing fetches

Fetchable includes basic support for performing the actual fetches via Runners
which can be run as cronjobs. Apps with large fetching demands should probably
fetch using a worker queuing system like Resque, Sidekiq, or Sneakers.

### Future plans

Track permanent redirects in another table

Possible options in the future:
* detect file type
* changed\_at: Recognise same content transmission via fingerprint (pseudo-304) and allowing the app developer to decide if a file has semantically changed by returning true/false to the after\_fetch callback.
* diagnostic logs
* smart scheduling - using previous change-events to predict next fetch time (e.g. [mean-3\*stdev, standad\_fetch\_period].min])
* dynamically decide what to persist. attribs not in DB retained as local attributes
* option to enforce unique URLs (and maybe canonical URLs)

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
