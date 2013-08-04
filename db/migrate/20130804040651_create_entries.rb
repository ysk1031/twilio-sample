class CreateEntries < ActiveRecord::Migration
  def change
    create_table :entries do |t|
      t.string :name
      t.string :email
      t.string :mobile_number
      t.string :verification_code
      t.boolean :verified, null: false, default: false

      t.timestamps
    end
  end
end
