namespace :psp do
  desc "Load manifests from config/psp_manifests into DB"
  task load_manifests: :environment do
    Dir[Rails.root.join("config/psp_manifests/*.yml")].each do |file|
      h = YAML.load_file(file)
      p = PspManifest.find_or_initialize_by(psp_id: h['psp_id'])
      p.manifest = h
      p.version = h['version']
      p.active = true
      p.save!
      puts "Loaded manifest for #{p.psp_id}"
    end
  end
end
