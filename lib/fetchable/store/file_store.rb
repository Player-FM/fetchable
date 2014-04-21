module Fetchable

  module Store

    class FileStore

      attr_accessor :folder, :name_prefix 

      def initialize(settings={})
        settings = Hashie::Mash.new(settings)
        #byebug
        @folder = settings.folder # we have to defer the default as Rails.root doesn't exist yet
        @name_prefix = settings.name_prefix || "res"
      end

      def get_folder
        @folder || "#{Rails.root}/public/resources"
      end

      def path(resource)
        "#{get_folder}/#{@name_prefix}#{Fetchable::Util.encode(resource.id)}.txt"
      end

      def save_content(resource, response, options)
        folder = get_folder
        FileUtils.mkdir_p(folder) unless File.directory?(folder)
        File.open(self.path(resource), 'wb') {|f| f.write(response.body) }
      end

    end

  end

end
