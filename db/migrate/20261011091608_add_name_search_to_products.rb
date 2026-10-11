class AddNameSearchToProducts < ActiveRecord::Migration[8.1]
  def change
    add_column :products, :name_search, :string
    reversible do |dir|
      dir.up do
        Product.reset_column_information
        Product.find_each { |p| p.update_column(:name_search, Product.fold(p.name)) }
      end
    end
  end
end
