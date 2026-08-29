#!/usr/bin/env ruby
require "webrick"
require "net/http"

DEFAULT = "http://127.0.0.1:8081"

def cell_for(tenant)
  n = Integer(tenant) rescue nil
  return DEFAULT if n.nil?
  return "http://127.0.0.1:8082" if n == 2 || n == 3
  DEFAULT
end

server = WEBrick::HTTPServer.new(Port: 8090)
server.mount_proc "/" do |req, res|
  tenant = req["X-Tenant-Id"] || req.query["tenant"] || ""
  base   = cell_for(tenant)
  path   = req.path == "/" ? "/db" : req.path
  uri    = URI("#{base}#{path}")
  uri.query = req.query_string unless req.query_string.to_s.empty?

  up = Net::HTTP.get_response(uri)
  res.status = up.code.to_i
  res.body   = up.body
  res["X-Cell-Upstream"] = base
  res["X-Tenant-Id"] = tenant
end

trap("INT") { server.shutdown }
puts "Router http://127.0.0.1:8090  (X-Tenant-Id: 0|1 -> A, 2|3 -> B)"
server.start
