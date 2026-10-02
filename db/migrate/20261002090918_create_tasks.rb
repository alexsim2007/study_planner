class CreateTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :tasks do |t|
      t.string :title, null: false
      t.text :description
      t.date :deadline, null: false
      t.string :status, null: false, default: "pending"
      t.string :priority, null: false, default: "medium"

      t.references :subject, null: false, foreign_key: true

      t.timestamps
    end
  end
end