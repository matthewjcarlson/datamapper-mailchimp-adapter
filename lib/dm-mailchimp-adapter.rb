
module MailChimpAPI
   class CreateError < StandardError; end
   class ReadError < StandardError; end
   class DeleteError < StandardError; end
   class UpdateError < StandardError; end
end
module DataMapper
  module Adapters
    class MailchimpAdapter < AbstractAdapter

      def initialize(name, uri_or_options)
        super(name, uri_or_options)    
      end

      def create(resources)
        raise NotImplementedError
      end

      def read_many(query)
        raise NotImplementedError
      end
      
      def read_one(query)
        raise NotImplementedError
      end
      
      def update(attributes, query)
        raise NotImplementedError
      end
      
      def delete(query)
        raise NotImplementedError
      end
      
    end  
  end
end



