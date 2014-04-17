module Dummy

  TESTDATA_HOST = 'http://testdata.biz'
  TESTFILE_HOST = 'http://testdata.biz/file.php'

  def self.test_file(params={})
    uri = Addressable::URI.parse(TESTFILE_HOST)
    uri.query_values = params
    puts uri.to_s
    uri.to_s
  end

end

# Dummy::TEST_URL = 'http://testdata.player.fm'
