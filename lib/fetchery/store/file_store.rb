module Fetchery

  module Store

    class FileStore

      attr_accessor :folder, :name_prefix 

      def initialize(settings={})
        settings = Hashie::Mash.new(settings)
        @folder = settings.folder || "#{Rails.root}/public/resources"
        @name_prefix = settings.name_prefix || "res"
      end

      def path(resource)
        "#{@folder}/#{@name_prefix}#{Fetchery::Util.encode(resource.id)}.txt"
      end

      def save_content(resource, response, options)
        FileUtils.mkdir_p(@folder) unless File.directory?(@folder)
        File.open(self.path(resource), 'wb') {|f| f.write(response.body) }
      end

    end

  end

end
