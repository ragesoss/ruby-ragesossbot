# frozen_string_literal: true
require 'mediawiki_api'
require 'yaml'
require 'json'

#= This class is for getting data directly from the MediaWiki API.
class WikiApi
  def initialize
    @api_url = 'https://en.wikipedia.org/w/api.php'
    api_client_login
  end

  ###########
  # Queries #
  ###########

  # General entry point for making arbitrary queries of a MediaWiki wiki's API
  def query(query_parameters)
    mediawiki('query', query_parameters)
  end

  def get_page_content(page_title)
    response = mediawiki('get_wikitext', page_title)
    response.status == 200 ? response.body : nil
  end

  def get_user_id(username)
    user_query = { list: 'users',
                   ususers: username }
    user_data = mediawiki('query', user_query)
    return unless user_data.data['users'].any?
    user_id = user_data.data['users'][0]['userid']
    user_id
  end

  def get_page_info(titles)
    query_params = { prop: 'info',
                     titles: titles }
    response = query(query_params)
    response.status == 200 ? response.data : nil
  end

  ####################
  # Basic edit types #
  ####################

  def post_whole_page(page_title, content, summary = nil)
    params = { title: page_title,
               text: content,
               summary: summary,
               format: 'json' }

    mediawiki_edit params
  end

  def add_new_section(page_title, message)
    params = { title: page_title,
               section: 'new',
               sectiontitle: message[:sectiontitle],
               text: message[:text],
               summary: message[:summary],
               format: 'json' }

    mediawiki_edit params
  end

  def add_to_page_top(page_title, content, summary)
    params = { title: page_title,
               prependtext: content,
               summary: summary,
               format: 'json' }

    mediawiki_edit params
  end

  ###################
  # Private methods #
  ###################
  private

  def mediawiki_edit(params)
    @client.action :edit, params
  end

  def mediawiki(action, query)
    @client.send(action, query)
  end

  def api_client
    @client ||= MediawikiApi::Client.new @api_url
  end

  def api_client_login
    config = YAML.load File.read('login.yml')
    api_client.log_in config['username'], config['password']
  end
end
