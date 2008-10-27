module DataMapper
  module Resource
    module MailingListModel
      
      def self.include(base)
        base.send :property, :email, String
      end
      
    end # MailingListModel
  end # Resource
end # DataMapper