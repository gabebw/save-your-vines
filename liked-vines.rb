#!/usr/bin/env ruby

require "json"
require "net/https"
require "uri"

def parse(data)
  JSON.parse(data, symbolize_names: true)
end

def POST(url, data)
  uri = URI.parse(url)
  response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
    request = Net::HTTP::Post.new(uri)
    request.set_form_data(data)
    # The default User-Agent for Net::HTTP is "Ruby". That crashes Vine's
    # server(!) and causes a 500 error.
    request["User-Agent"] = "Almost anything else"
    http.request(request)
  end
  parse(response.body)
end

def GET(url, session_id, data={})
  uri = URI.parse(url)
  uri.query = URI.encode_www_form(data)

  response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
    request = Net::HTTP::Get.new(uri)
    request["User-Agent"] = "Almost anything else"
    request["vine-session-id"] = session_id
    http.request(request)
  end
  parse(response.body)
end

def sign_in(username, password)
  json = POST(
    "https://api.vineapp.com/users/authenticate",
    "username" => username,
    "password" => password,
  )
  if json[:error] != ""
    STDERR.puts "Your username or password is wrong; please double-check and run this script again"
    exit 1
  end
  json[:data][:key]
end

def get_likes(session_id, page_number = 1)
  STDERR.puts "Getting likes (page #{page_number})"
  url = "https://api.vineapp.com/timelines/users/me/likes"

  json = GET(url, session_id, page: page_number)
  likes = json[:data][:records].map do |record|
    {
      created_at: record[:created],
      description: record[:description],
      mp4: record[:videoUrl],
      mp4_backup: record[:videoDashUrl],
      username: record[:username],
      vine_url: record[:permalinkUrl],
      webm: record[:videoWebmUrl],
    }
  end

  if json[:data][:nextPage]
    likes += get_likes(session_id, page_number + 1)
  end

  likes
end

vine_username = ARGV[0].chomp
vine_password = ARGV[1].chomp

session_id = sign_in(vine_username, vine_password)
all_likes = get_likes(session_id)
puts JSON.dump(all_likes)
