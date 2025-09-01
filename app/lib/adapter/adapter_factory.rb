# app/lib/adapter/adapter_factory.rb
class Adapter::AdapterFactory
  def self.for(psp_id)
    manifest = PspManifest.find_by(psp_id: psp_id)
    raise "No manifest for #{psp_id}" unless manifest
    Adapter::Runtime.new(manifest)
  end

  def self.default_psp
    # simple: pick first active manifest - make it smarter later
    PspManifest.active.first&.psp_id
  end
end
