class CreateEvmHistories < ActiveRecord::Migration
  def change
    create_table :evm_histories do |t|

      t.integer :project_id

      t.float :bac

      t.float :pv

      t.float :ev

      t.float :av

      t.timestamps :null => false
    end
  end
end
