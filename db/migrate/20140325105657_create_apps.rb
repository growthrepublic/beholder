class CreateApps < ActiveRecord::Migration
  def change
    create_table :apps do |t|
      t.string :name
      t.string :url
      t.string :server
      t.string :aasm_state
      t.string :repository_url
      t.string :project_url
      t.text :description

      t.timestamps
    end
  end
end
