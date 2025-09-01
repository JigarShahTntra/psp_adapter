# app/lib/mapping_engine.rb
require 'liquid'

class MappingEngine
  # template_map is a Hash of field paths -> Liquid template string
  # ctx is the canonical request hash
  def self.map_request(template_map, ctx)
    ctx = ctx.with_indifferent_access
    output = {}
    template_map.each do |target_path, template_str|
      tpl = Liquid::Template.parse(template_str)
      rendered = tpl.render(ctx)
      # naive set_into_hash - support nested keys by dot notation
      set_into_hash(output, target_path, rendered)
    end
    output
  end

  def self.set_into_hash(h, dotted_key, value)
    parts = dotted_key.split('.')
    last = parts.pop
    cur = h
    parts.each do |p|
      cur[p] ||= {}
      cur = cur[p]
    end
    # attempt JSON parse for structured values
    begin
      parsed = JSON.parse(value)
      cur[last] = parsed
    rescue
      cur[last] = value
    end
  end
end
