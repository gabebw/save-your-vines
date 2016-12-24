#!/usr/bin/env ruby

require "fileutils"
require "json"
require "open-uri"
require "time"

JEKYLL_DIRECTORY = "./docs"
VINES_DIRECTORY = "#{JEKYLL_DIRECTORY}/vines"

def presence(s, fallback)
  if s == "" || s.nil?
    fallback
  else
    s
  end
end

def normalize_title(title)
  title.gsub("/", "%2F")
end

def download_and_make_blog_post(json)
  vine_id = File.basename(json[:vine_url])
  directory = "#{VINES_DIRECTORY}/#{vine_id}"
  description = presence(json[:description], "[No title]")
  title = "#{description} by #{json[:username]}"
  puts "Downloading and creating blog post for #{json[:vine_url]} (#{title})"

  FileUtils.mkdir_p(directory)
  created_at = Time.parse(json[:created_at])
  filename = "#{directory}/#{vine_id}"
  mp4_src = "/#{File.basename(VINES_DIRECTORY)}/#{vine_id}/#{vine_id}.mp4"
  webm_src = "/#{File.basename(VINES_DIRECTORY)}/#{vine_id}/#{vine_id}.webm"
  year = created_at.strftime("%Y")
  month = created_at.strftime("%m")
  day = created_at.strftime("%d")
  post_filename = "#{JEKYLL_DIRECTORY}/_posts/#{year}-#{month}-#{day}-#{normalize_title(title)}.html"

  unless File.exist?("#{filename}.mp4")
    File.open("#{filename}.mp4", "wb") do |mp4_file|
      open(json[:mp4], "rb") { |f| mp4_file.write(f.read) }
    end
  end

  if json[:webm]
    unless File.exist?("#{filename}.webm")
      File.open("#{filename}.webm", "wb") do |webm_file|
        open(json[:webm], "rb") { |f| webm_file.write(f.read) }
      end
    end
  end

  File.open(post_filename, "w") do |f|
    f.write(blog_post_contents(json, title, created_at, mp4_src, webm_src))
  end
end

def blog_post_contents(json, title, created_at, mp4_src, webm_src)
<<EOF
---
title: >
  #{title}
date: "#{created_at.strftime("%Y-%m-%d %H:%M:%S %z")}"
layout: post
---

#{video_tag(json, mp4_src, webm_src)}

<p><a href="#{json[:vine_url]}">Original Vine</a> by #{json[:username]}</p>
EOF
end

def video_tag(json, mp4_src, webm_src)
  tag = '<video loop controls autoplay width="540" height="540">'
  tag += %{\n  <source type="video/mp4" src="{{ site.baseurl }}#{mp4_src}" />}
  if json[:webm]
    tag += %{\n  <source type="video/webm" src="{{ site.baseurl }}#{webm_src}" />}
  end
  tag += "\n</video>"
  tag
end

JSON.parse(File.read(ARGV[0]), symbolize_names: true).each do |json|
  begin
    download_and_make_blog_post(json)
  rescue Exception => e
    p json
    puts e
    puts e.backtrace
    vine_id = File.basename(json[:vine_url])
    directory = "#{VINES_DIRECTORY}/#{vine_id}"
    FileUtils.rm_rf(directory)
    exit 1
  end
end
