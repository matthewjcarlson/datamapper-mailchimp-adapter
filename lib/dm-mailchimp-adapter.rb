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
      attr_reader :client, :authorization, :mailing_list_id
      CHIMP_URL = "http://api.mailchimp.com/1.1/" 
      def initialize(name, uri_or_options)
        super(name, uri_or_options)
        @client = XMLRPC::Client.new2(CHIMP_URL)  
        @authorization = @client.call("login", uri_or_options[:username], uri_or_options[:password]) 
        @mailing_list_id = uri_or_options[:mailing_list_id]
      end

      def create(resources)
        resources.each do |resource|
          chimp_subscribe(resource)
        end
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
      def chimp_subscribe(resource, email_content_type="html", double_optin=true)
        begin
          @client.call("listSubscribe", @authorization, get_mailing_list(resource), resource.email, resource.build_mail_merge(), email_content_type, double_optin)
        rescue XMLRPC::FaultException => e
          raise CreateError e.faultString
        end    
      end
      
      def chimp_remove(options, delete_user=false, send_goodbye=true, send_notify=true)
        begin
          @client.call("listUnsubscribe", @authorization, options[:mailing_list_id], options[:email], delete_user, send_goodbye, send_notify) 
        rescue XMLRPC::FaultException => e
          raise DeleteError e.faultString
        end   
      end
      
      def chimp_update(options, email_content_type="html", replace_interests=false)
        begin
          @client.call("listUpdateMember", @authorization, options[:mailing_list_id], options[:email], email_content_type, replace_interests) 
        rescue XMLRPC::FaultException => e
          raise UpdateError e.faultString
        end   
      end
      
      def chimp_read_member(options)
        begin
          @client.call("listMemberInfo", @authorization, options[:mailing_list_id], options[:email])  
        rescue XMLRPC::FaultException => e
          raise ReadError e.faultString
        end  
      end
      
      def chimp_all_members(options)
        begin
          @client.call("listMembers", @authorization, options[:mailing_list_id], options[:email], options[:page], options[:limit])
        rescue XMLRPC::FaultException => e
          raise ReadError e.faultString
        end    
      end
      
      def get_mailing_list(resource)
         unless @mailing_list_id.nil?
            mailing_list_id = @mailing_list_id
          else
            mailing_list_id = resource.mailing_list_id
          end
      end
        
    end  
  end
end



