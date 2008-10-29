require 'xmlrpc/client'
require 'dm-core'
require 'pp'
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
        created = 0
        if resources.size > 1
          batch = Array.new(resources.size)
          resources.each do |resource|
            batch << resource.build_mail_merge
            created += 1
          end
          chimp_batch_subscribe(batch)
        else
           chimp_subscribe(resources.first)
           created += 1
        end
        created
      end

      def read_many(query)
        Collection.new(query) do |set|
          results = chimp_all_members(extract_query_options(query))
          if results
            results.each do |result|
            data = query.fields.map do |property|        
              property.typecast(result[property.field.to_s])
            end
            set.load(data)  
            end  
          end 
        end
      end
      
      def read_one(query)
        result = chimp_read_member(extract_query_options(query))
        if result
          query.model.load(
            query.fields.map do |property|        
              property.typecast(result[property.field.to_s])
            end,
            query
          )
        end
      end
    
      def update(attributes, query)
        updated = 0
        chimp_update(extract_query_options(query), extract_update_options(attributes))
        updated += 1
      end
      
      def delete(query) 
        deleted = 0
        chimp_remove(extract_query_options(query))
        deleted += 1
      end
      
      
      private
      def chimp_subscribe(resource, email_content_type="html", double_optin=true)
        begin
          @client.call("listSubscribe", @authorization, get_mailing_list_from_resource(resource), resource.email, resource.build_mail_merge(), email_content_type, double_optin)
        rescue XMLRPC::FaultException => e
          raise MailChimpAPI::CreateError, e.faultString
        end    
      end
      
      def chimp_batch_subscribe(resource, email_content_type="html", double_optin=true, update_existing=true, replace_interests=false)
        begin
          @client.call("listBatchSubscribe", @authorization, get_mailing_list_from_resource(resource), resource.email, , double_optin, update_existing, replace_interests)
        rescue XMLRPC::FaultException => e
          raise MailChimpAPI::CreateError, e.faultString
        end    
      end
      
      def chimp_remove(options, delete_user=false, send_goodbye=true, send_notify=true)
        begin
          raise MailChimpAPI::DeleteError("Email and Mailing List Id can't be nil") if (options[:email].nil? || options[:mailing_list_id].nil?)
          @client.call("listUnsubscribe", @authorization, options[:mailing_list_id], options[:email], delete_user, send_goodbye, send_notify) 
        rescue XMLRPC::FaultException => e
          raise MailChimpAPI::DeleteError, e.faultString
        end   
      end
      
      def chimp_update(options, merge_vars, email_content_type="html", replace_interests=false)
        begin
          @client.call("listUpdateMember", @authorization, options[:mailing_list_id], options[:email], merge_vars, email_content_type, replace_interests) 
        rescue XMLRPC::FaultException => e
          raise MailChimpAPI::UpdateError, e.faultString
        end   
      end
      
      def chimp_read_member(options)
        begin
          raise MailChimpAPI::ReadError("Email can't be nil") if (options[:email].nil?) 
          @client.call("listMemberInfo", @authorization, options[:mailing_list_id], options[:email])  
        rescue XMLRPC::FaultException => e
          raise MailChimpAPI::ReadError, e.faultString
        end  
      end
      
      def chimp_all_members(options)
        begin
          @client.call("listMembers", @authorization, options[:mailing_list_id], options[:status], 0, 10)
        rescue XMLRPC::FaultException => e
          raise MailChimpAPI::ReadError, e.faultString
        end    
      end
      
       def chimp_lists
          begin
            @client.call("lists", @authorization)
          rescue XMLRPC::FaultException => e
            raise MailChimpAPI::ReadError, e.faultString
          end    
        end
      
      def get_mailing_list_from_resource(resource)
        unless @mailing_list_id.nil?
          mailing_list_id = @mailing_list_id
        else
          mailing_list_id = resource.mailing_list_id
        end
      end
     
      def extract_update_options(attributes)
        merge_vars = {} 
        attributes.each do |prop,val|
           case prop.name
             when "email" then merge_vars.merge!("EMAIL" => val)
             when "first_name" then merge_vars.merge!("FNAME" => val)
             when "last_name" then merge_vars.merge!("LNAME" => val)
           end
        end
        merge_vars
      end
      
      def extract_query_options(query)
        options = {}
        options.merge!(:mailing_list_id => @mailing_list_id) 
        options.merge!(:status => 'active')
        query.conditions.each do |condition|
          operator, property, value = condition
          case property.name
            when :mailing_list_id then options.merge!(:mailing_list_id => value) 
            when :email then options.merge!(:email => value) 
            when :status then options.merge!(:status => value) 
            when :key then options.merge!(:email => value)
          end
        end
        options
      end
        
    end  
  end
end



