class CreateThermostatReadings < ActiveRecord::Migration[6.0]
  def change
    create_table :thermostat_readings do |t|
      t.references :thermostat,
                   null: false,
                   foreign_key: {
                    on_delete: :cascade,
                    on_update: :cascade
                   }

      t.integer :sequence_number, null: false
      t.float :temperature, null: false
      t.float :humidity, null: false
      t.float :battery_charge, null: false

      t.timestamps
    end
    add_index :thermostat_readings, [:thermostat_id, :sequence_number], unique: true
  end
end
