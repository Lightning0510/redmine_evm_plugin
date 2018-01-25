class CreateEvms < ActiveRecord::Migration
  def change
    create_table :evms do |t|

      t.integer :project_id


    end

  end
end
