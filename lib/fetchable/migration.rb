# Adapted from https://github.com/delynn/userstamp/blob/master/lib/userstamp/migration_helper.rb

module Fetchable
  module MigrationHelper
    def self.included(base) # :nodoc:
      base.send(:include, InstanceMethods)
    end

    module InstanceMethods
      def fetchable_attribs

        column :url, :string

        # call properties
        column :status_code, :integer
        column :last_modified, :datetime
        column :size, :integer
        column :etag, :string
        column :fingerprint, :string
        column :redirect_chain, :string
        column :permanent_redirect_url, :string
        column :received_content_type, :string
        column :inferred_content_type, :string

        # tracking over time
        column :fail_count, :integer, default: 0, nil: false
        column :next_fetch_after, :datetime, default: DateTime.new(1970,1,1), nil: false
        column :fetched_at, :datetime
        column :refetched_at, :datetime
        column :failed_at, :datetime
        column :tried_at, :datetime

      end
    end
  end
end

ActiveRecord::ConnectionAdapters::TableDefinition.send(:include, Fetchable::MigrationHelper)
