### Acts As Fetchable

This Rails plugin helps you sync ActiveRecords with any online content, such as
web pages, images, RSS feeds. Examples of use:

* Periodically access your users' Twitter profiles so you can store their
  latest bios and image URLs.
* Save a batch of specified images. For example, cache users' social media
  avatars as you normally can't hot-link them.
* Periodically parse some RSS feeds.
* Make a small search engine by periodically retrieving a list of sites.

Notes:

* Not complete yet - the examples below are partly a roadmap and won't all
  work.
* It's my first Rails gem, so I'm learning as I go here.

### Basic usage

Fetchable makes HTTP calls for you, retaining the results.

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

Fetchable conserves internet energy. HTTP "memento" standards (ETags and
timestamp) are leveraged to avoid unnecessary work.

    image.fetch # first fetch creates a resource record
    puts image.status # 200
    image.fetch # second re-fetch only does a full download if the image changed
    puts image.status # 304

### Callbacks

Fetchable lets you register for interesting fetch events, just like the regular
ActiveRecord callbacks.

    class Image < ActiveRecord::Base

      acts_as_fetchable

      fetch_started :cancel_if_server_too_busy
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

### Batch fetching

Fetchable includes basic support for batch-fetching all of your records via
Runners which can be run as cronjobs. Apps with large fetching demands should
probably fetch using a worker queuing system like Resque, Sidekiq, or Sneakers.
Some examples will appear here for using those.

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

Create or update your model using the "fetchable\_attribs" migration helper demonstrated below. The update helper will add whatever extra columns are required, so you should be able to run it to upgrade to the latest version of this library. (It makes no attempt to delete any deprecated columns, you'll need to do that yourself if you feel the data can be discarded.) It will create the necessary attributes. If you prefer to do it manually, [here is the list of attributes](lib/fetchable/migration) your table needs.

    # Make a new fetchable model
    class CreateDocuments < ActiveRecord::Migration
      def change
        create_table :documents do |t|
          t.integer :word_count
          t.fetchable_attribs
          t.timestamps
        end
      end
    end

    # Make existing model fetchable
    class UpdateDocuments < ActiveRecord::Migration
      def change
        add_fetchable_attribs :documents
      end
    end

  The class simply needs to include `acts_as_fetchable` as shown in the examples above.

  class Document < ActiveRecord::Base
    acts_as_fetchable
  end

### Contributing

Pull requests are welcome. Please include test coverage for any new feature and
ensure it passes [Travis](https://travis-ci.org/playerfm/fetchable). You can
run tests as follows (convenient syntax thanks to single\_test gem for
convenient specification of the test cases):

> alias brake='bundle exec rake' # it's just easier, innit
> brake # runs all tests
> brake test:FetchableTest # run a single test class
> brake test:FetchableTest:test\_attribs # run a single test method

The tests make calls to a TestData instance at http://testdata.player.fm, which
is a project that provides controllable and deterministic example RESTful
calls. The remote server is fine, but it's faster to run tests locally by
installing the [testdata](https://github.com/playerfm/testdata) server if
you're so inclined.  Once running on your machine, point the environment
variable TESTDATA\_HOST to your local server.
