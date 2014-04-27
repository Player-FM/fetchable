module Fetchable

  module Stores

    class FileStore

      attr_accessor :folder, :name_prefix 

      def initialize(settings={})
        settings = Hashie::Mash.new(settings)
        #byebug
        @folder = settings.folder # we have to defer the default as Rails.root doesn't exist yet
        @name_prefix = settings.name_prefix || "res"
      end

      def get_folder
        @folder || "#{Rails.root}/public/fetchables"
      end

      def key_of(fetchable)
        "#{get_folder}/#{@name_prefix}#{Fetchable::Util.encode(fetchable.id)}#{self.class.determine_extension fetchable}"
      end

      def save_content(fetchable, response, options)
        folder = get_folder
        FileUtils.mkdir_p(folder) unless File.directory?(folder)
        File.open(self.key_of(fetchable), 'wb') {|f| f.write(response.body) }
      end

      def self.determine_extension(fetchable)
        types = MIME::Types[fetchable.received_content_type]
        types = MIME::Types[fetchable.inferred_content_type] if types.blank?
        if types and types.first and extension = types.first.extensions[0]
          ".#{extension}"
        else
          ''
        end
      end

    end

  end

end
