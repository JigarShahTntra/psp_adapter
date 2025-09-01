class CreatePspManifests < ActiveRecord::Migration[7.2]
  def change
    create_table :psp_manifests do |t|
      t.string :psp_id
      t.jsonb :manifest
      t.string :version
      t.boolean :active

      t.timestamps
    end
  end
end
