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
        chimp_all_members(extract_query_options(query))
      end
      
      def read_one(query)
        chimp_read_member(extract_query_options(query))
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
          @client.call("listSubscribe", @authorization, get_mailing_list_from_resource(resource), resource.email, resource.build_mail_merge(), email_content_type, double_optin)
        rescue XMLRPC::FaultException => e
          raise CreateError(e.faultString)
        end    
      end
      
      def chimp_remove(options, delete_user=false, send_goodbye=true, send_notify=true)
        begin
          raise ReadError("Email and Mailing List Id can't be nil") if (options[:email].nil? || options[:mailing_list_id].nil?)
          @client.call("listUnsubscribe", @authorization, options[:mailing_list_id], options[:email], delete_user, send_goodbye, send_notify) 
        rescue XMLRPC::FaultException => e
          raise DeleteError(e.faultString)
        end   
      end
      
      def chimp_update(options, merge_vars, email_content_type="html", replace_interests=false)
        begin
          @client.call("listUpdateMember", @authorization, options[:mailing_list_id], options[:email], merge_vars, email_content_type, replace_interests) 
        rescue XMLRPC::FaultException => e
          raise UpdateError(e.faultString)
        end   
      end
      
      def chimp_read_member(options)
        begin
          raise ReadError("Email can't be nil") if (options[:email].nil?) 
          @client.call("listMemberInfo", @authorization, options[:mailing_list_id], options[:email])  
        rescue XMLRPC::FaultException => e
          raise ReadError(e.faultString)
        end  
      end
      
      def chimp_all_members(options)
        begin
          @client.call("listMembers", @authorization, options[:mailing_list_id], options[:status], 1, 10)
        rescue XMLRPC::FaultException => e
          raise ReadError(e.faultString)
        end    
      end
      
      def get_mailing_list_from_resource(resource)
        unless @mailing_list_id.nil?
          mailing_list_id = @mailing_list_id
        else
          mailing_list_id = resource.mailing_list_id
        end
      end
     
      
      def extract_query_options(query)
        options = {}
        options.merge!(:mailing_list_id => @mailing_list_id) 
        options.merge!(:status => 'subscribed')
       
        query.conditions.each do |condition|
          operator, property, value = condition
          case property.name
            when :mailing_list_id then options.merge!(:mailing_list_id => value) 
            when :email then options.merge!(:email => value) 
            when :status then options.merge!(:status => value) 
          end
        end
        options
      end
        
    end  
  end
end



