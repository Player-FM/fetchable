module Dummy

  TESTDATA_HOST = ENV['TESTDATA_HOST'] || 'http://testdata.player.fm'

  TESTFILE_HOST = "#{TESTDATA_HOST}/file.php"
  TESTFEED_HOST = "#{TESTDATA_HOST}/index.php"

  def self.test_file(params={})
    uri = Addressable::URI.parse(TESTFILE_HOST)
    uri.query_values = params
    puts uri.to_s
    uri.to_s
  end

  def self.test_feed(params={})
    uri = Addressable::URI.parse(TESTFEED_HOST)
    uri.query_values = params
    puts uri.to_s
    uri.to_s
  end

end

# Dummy::TEST_URL = 'http://testdata.player.fm'
