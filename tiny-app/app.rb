require "rack"
require "pg"

class App
  def self.call(env)
    req = Rack::Request.new(env)

    case req.path_info
    when "/health"
      [200, { "content-type" => "text/plain" }, ["ok\n"]]
    when "/", "/db"
      body = check_db
      [200, { "content-type" => "text/plain" }, [body]]
    else
      [404, { "content-type" => "text/plain" }, ["not found\n"]]
    end
  end

  def self.check_db
    conn = PG.connect(
      host: ENV.fetch("PGHOST"),
      port: ENV.fetch("PGPORT", "5432"),
      dbname: ENV.fetch("PGDATABASE"),
      user: ENV.fetch("PGUSER"),
      password: ENV.fetch("PGPASSWORD")
    )
    row = conn.exec("SELECT current_database() AS db, current_user AS user, inet_server_addr()::text AS server").first
    conn.close
    "db=#{row['db']} user=#{row['user']} server=#{row['server']}\n"
  rescue => e
    "DB ERROR: #{e.class}: #{e.message}\n"
  end
end
