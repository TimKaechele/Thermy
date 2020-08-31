class CreateThermostats < ActiveRecord::Migration[6.0]
  def change
    create_table :thermostats do |t|
      t.string :household_token, null: false
      t.string :street, null: false
      t.string :zip_code, null: false
      t.string :city, null: false
      t.string :country, null: false

      t.timestamps
    end

    add_index :thermostats, :household_token, unique: true
  end
end
