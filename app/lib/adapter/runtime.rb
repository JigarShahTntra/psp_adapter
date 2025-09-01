# app/lib/adapter/runtime.rb
require "faraday"

module Adapter
  class Runtime
    def initialize(psp_manifest)
      @manifest = psp_manifest.manifest_hash
      @base_url = @manifest["base_url"]
      @auth = @manifest["auth"] || {}
      @conn = Faraday.new(url: @base_url) do |f|
        f.request :json
        f.response :raise_error
        f.adapter Faraday.default_adapter
      end
    end

    def authorize(canonical_hash)
      op = @manifest["operations"]["authorize"]
      req_map = op["request"]["map"] || {}
      # render mapping
      payload = MappingEngine.map_request(req_map, deep_stringify_keys(canonical_hash))
      # auth
      headers = auth_headers
      # send
      resp = @conn.post(op["path"], payload, headers)
      body = parse_body(resp)
      normalized = map_response(op["response"], body)
      normalized
    rescue Faraday::ClientError => e
      { "status" => "error", "error" => e.message }
    end

    private

    def parse_body(resp)
      JSON.parse(resp.body) rescue resp.body
    end

    def map_response(resp_config, body)
      tpl = resp_config["map"] || {}
      result = {}
      tpl.each do |k, v|
        # if v has Liquid placeholders referring to response, we render
        rendered = Liquid::Template.parse(v).render("response" => body)
        result[k] = rendered
      end
      result
    end

    def auth_headers
      case @auth["type"]
      when "bearer"
        token = ENV[@auth["env_token_key"]] || @auth["token"]
        { "Authorization" => "Bearer #{token}" }
      else
        {}
      end
    end

    def deep_stringify_keys(obj)
      case obj
      when Hash
        obj.each_with_object({}) { |(k,v), h| h[k.to_s] = deep_stringify_keys(v) }
      when Array
        obj.map { |i| deep_stringify_keys(i) }
      else
        obj
      end
    end
  end
end
