require 'xmlrpc/client'
require 'dm-core'
module MailChimpAPI
   class CreateError < StandardError; end
   class ReadError < StandardError; end
   class DeleteError < StandardError; end
   class UpdateError < StandardError; end
end

module DataMapper
  module Adapters
    class MailchimpAdapter < AbstractAdapter
      attr_reader :client, :authorization
      CHIMP_URL = "http://api.mailchimp.com/1.1/" 
      def initialize(name, uri_or_options)
        super(name, uri_or_options)
        @client = XMLRPC::Client.new2(CHIMP_URL)  
        @authorization = @client.call("login", Merb::Config[:chimp_settings]['mail_chimp']['username'], Merb::Config[:chimp_settings]['mail_chimp']['password']) 
      end

      def create(resources)
       chimp_subscribe(options)
      end

      def read_many(query)
        chimp_all_members(query)
      end
      
      def read_one(query)
        chimp_read_member(query)
      end
      
      def update(attributes, query)
        chimp_update(options)
      end
      
      def delete(query)
        chimp_remove(options)
      end
      
      private
      def chimp_subscribe(options, email_content_type="html", double_optin=true)
        begin
          @client.call("listSubscribe", @authorization, options[:mailing_list_id], options[:email], options[:merge_vars], email_content_type, double_optin)
        rescue XMLRPC::FaultException => e
          Merb.logger e.faultCode
          Merb.logger e.faultString
        end    
      end
      
      def chimp_remove(options, delete_user=false, send_goodbye=true, send_notify=true)
        @client.call("listUnsubscribe", @authorization, options[:mailing_list_id], options[:email], delete_user, send_goodbye, send_notify)    
      end
      
      def chimp_update(options, email_content_type="html", replace_interests=false)
        @client.call("listUpdateMember", @authorization, options[:mailing_list_id], options[:email], email_content_type, replace_interests)    
      end
      
      def chimp_read_member(options)
        @client.call("listMemberInfo", @authorization, options[:mailing_list_id], options[:email])    
      end
      
      def chimp_all_members(options)
        @client.call("listMembers", @authorization, options[:mailing_list_id], options[:email], options[:page], options[:limit])    
      end
    end  
  end
end



