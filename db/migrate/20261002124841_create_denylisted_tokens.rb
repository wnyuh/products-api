class CreateDenylistedTokens < ActiveRecord::Migration[8.1]
  def change
    create_table :denylisted_tokens do |t|
      t.string :jti
      t.datetime :exp

      t.timestamps
    end
    add_index :denylisted_tokens, :jti, unique: true
  end
end
