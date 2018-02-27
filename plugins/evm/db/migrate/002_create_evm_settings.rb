class CreateEvmSettings < ActiveRecord::Migration
  def change
    create_table :evm_settings do |t|
      t.integer :project_id

      t.integer :save_histories, :default => 0

    end
  end
end
