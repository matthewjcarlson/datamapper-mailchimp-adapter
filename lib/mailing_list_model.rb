module DataMapper
  module Resource
    module MailingListModel
      def self.include(base)   
        base.send :property :first_name, String
        base.send :property :last_name, String
        base.send :property :email, String, :key => true
        base.send :property :status, String
        base.send :property :email_type, String
        base.send :property :mailing_list_id, String
        base.send :property :merges, String
        base.send :property :ip_signup, String
        base.send :property :ip_opt, String
        base.send :property :timestamp, String
      end
      
    end # MailingListModel
  end # Resource
end # DataMapper